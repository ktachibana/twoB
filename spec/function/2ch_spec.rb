# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'

describe "2chのスレッドを読む" do
  include BBS2ch
  
  def view_thread(delta_input)
    @request = TwoB::Request.new("/server.2ch.net/board/123/l50#firstNew")
    @system = SpecSystem.new(@request)
    BBS2ch::ThreadService.__send__(:define_method, :get_new_input) do |request|
      delta_input
    end
    @system.process
    @response = @system.response
    @thread = @response.document
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
  end
  
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end
  
  def valid_thread(thread)
    thread.dat_link.attribute("href").text.should == "http://server.2ch.net/board/dat/123.dat"
    thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
  end
  
  it "トリップ付きレスを表示" do
    SpecSystem.clear_cache_dir
    view_thread(BinaryFile.by_filename("testData/2ch/with-trip.dat"))
    
    valid_response
    
    thread = @response.document
    Nokogiri::HTML.parse(@response.string, nil)
  end

  it "キャッシュなしの初回読み込み" do
    SpecSystem.clear_cache_dir
    
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))

    valid_response

    thread = @response.document
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
    SpecSystem.clear_cache_dir
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))
    view_thread(BinaryFile.by_filename("testData/2ch/example(81-100).dat"))

    valid_response

    thread = @response.document
    valid_thread(thread)
    thread.res_ranges.should == [1..1, 51..100]
    thread[1].should_not be_new
    thread[80].should_not be_new
    thread[81].should be_new
    thread[100].should be_new
  end
  
  it "追加読み込みしたが新着が無かった" do
    SpecSystem.clear_cache_dir
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))
    view_thread(StringInput.empty)

    valid_response
    
    thread = @response.document
    valid_thread(thread)
    thread.res_ranges.should == [1..1, 31..80]
  end
  
  it "レスアンカー表示" do
    pending("2chのレスアンカー表示は未実装")
    @request = TwoB::Request.new("/server.2ch.net/board/123/res_anchor", {"range"=> ["10-20"]})
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    valid_response
    anchor = @response.document
    anchor[9].should_not be_exist
    anchor[10].should be_exist
  end
  
  it "スレッドのキャッシュを削除" do
    SpecSystem.clear_cache_dir
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))

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
  
end
