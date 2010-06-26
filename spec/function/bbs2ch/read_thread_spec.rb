# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'
require 'bbs2ch/action'

describe "2chのスレッドを読む" do
  include BBS2ch
  include BBS2ch::Spec
  
  before do
    SpecSystem.clear_cache_dir
    @test_data_dir = Pathname.new("testData/2ch")
    @example_1to80 = BinaryFile.new(@test_data_dir + "example(1-80).dat")
    @example_81to100 = BinaryFile.new(@test_data_dir + "example(81-100).dat")
    @example_subject = TextFile.new(@test_data_dir + "example-subject.txt", "Windows-31J")
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
  end
  
  def valid_thread(thread)
    thread.dat_link.attribute("href").text.should == "http://server.2ch.net/board/dat/123.dat"
    thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
  end
  
  it "トリップ付きレスを表示" do
    view_thread(BinaryFile.new(@test_data_dir + "with-trip.dat"))
    
    valid_response
    
    thread = @response.as_thread
    thread.title.should == "KDEスレ Part 8"
  end

  it "キャッシュなしの初回読み込み" do
    view_thread(@example_1to80)

    valid_response

    thread = @response.as_thread
    valid_thread(thread)
    thread.res_ranges.should == [1..80]
    thread[1].should be_new
    thread[80].should be_new
    
    created_cache = @board_dir + "123.dat"
    created_cache.size.should == 24832
    
    created_index = @board_dir + "123.index.yaml"
    index = YAML::load(File.read(created_index))
    index.cache_file_size.should == 24832
    index[1].should == 0
    index[2].should == 0x265
    index[3].should == 0x2fc
    index[80].should == 0x5fc0
  end
  
  it "追加読み込み" do
    view_thread(@example_1to80)
    view_thread(@example_81to100)

    valid_response

    thread = @response.as_thread
    valid_thread(thread)
    thread.res_ranges.should == [1..1, 76..100]
    thread[1].should_not be_new
    thread[80].should_not be_new
    thread[81].should be_new
    thread[100].should be_new
  end
  
  it "subscribe5による初回読み込み" do
    view_thread(@example_1to80, "subscribe5")
    valid_response

    @response.as_thread.res_ranges.should == [1..80]
  end
  
  it "subscribe5による追加読み込み" do
    view_thread(@example_1to80, "subscribe5")
    view_thread(@example_81to100, "subscribe5")
    valid_response
    
    thread = @response.as_thread
    valid_thread(thread)
    thread.res_ranges.should == [1..1, 76..100]
    thread[80].new?.should be_false
    thread[81].new?.should be_true
  end
  
  it "追加読み込みしたが新着が無かった" do
    view_thread(@example_1to80)
    view_thread(StringInput.empty)

    valid_response
    
    thread = @response.as_thread
    valid_thread(thread)
    thread.res_ranges.should == [1..1, 76..80]
  end
  
  it "スレッドのキャッシュを削除" do
    view_thread(@example_1to80)

    (@board_dir + "123.dat").should be_exist
    (@board_dir + "123.index.yaml").should be_exist

    @request = TwoB::Request.new("/server.2ch.net/board/123/delete_cache")
    @system = SpecSystem.new(@request)
    @system.process

    @response = @system.response
    @response.status_code.should == 303
    @response.headers["Location"].should == "../"
    (@board_dir + "123.dat").should_not be_exist
    (@board_dir + "123.index.marshal").should_not be_exist
  end
  
  it "スレッドの読み込みで既読カウントが正しく更新される" do
    view_thread_list(@example_subject)
    board = @response.as_document
    board.css(".body .count")[0].text.gsub(/\s+/, "").should == "0/80"

    view_thread(@example_1to80)
    view_thread_list(@example_subject)
    board = @response.as_document
    board.css(".body .count")[0].text.gsub(/\s+/, "").should == "80/80"

    view_thread(StringInput.empty, "-10")
    view_thread_list(@example_subject)
    board = @response.as_document
    board.css(".body .count")[0].text.gsub(/\s+/, "").should == "80/80"
  end
    
end
