# -*- coding: utf-8 -*-
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'

require 'jbbs/thread'

describe "JBBSのスレッドを読む" do
  include JBBS
  
  def view_thread(delta_input)
    @request = TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/l50#firstNew")
    @system = SpecSystem.new(@request)
    JBBS::ThreadService.__send__(:define_method, :get_new_input) do |picker|
      delta_input
    end
    @system.process
    @response = @system.response
    @thread = @response.document
  end
  
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end
  
  it "キャッシュなしの初回読み込み" do
    SpecSystem.clear_cache_dir
    
    view_thread(BinaryFile.by_filename("testData/jbbs/example(1-216).dat"))
    
    valid_response

    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should be_exist
    thread[216].should be_new
    thread[217].should_not be_exist
    created_cache = SpecSystem::SpecConfiguration.data_directory + "jbbs.livedoor.jp" + "category" + "123" + "456.dat"
    created_cache.size.should == 31178
  end
  
  it "追加読み込み" do
    # TODO exampleの実行順序に依存しているので、順序を保障するか実行のし直しが必要
    view_thread(BinaryFile.by_filename("testData/jbbs/example(217-226).dat"))

    valid_response

    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should_not be_new
    thread[176].should_not be_exist
    thread[177].should_not be_new
    thread[217].should be_new
    thread[226].should be_new
    thread[227].should_not be_exist
  end
  
  it "追加読み込みしたが新着が無かった" do
    view_thread(StringInput.empty)

    valid_response
    
    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should_not be_new
    thread[176].should_not be_exist
    thread[177].should_not be_new
    thread[226].should_not be_new
    thread[227].should_not be_exist
  end
  
  it "レスアンカー表示" do
    @request = TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/res_anchor", {"range"=> ["10-20"]})
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    valid_response
    anchor = @response.document
    anchor[9].should_not be_exist
    anchor[10].should be_exist
  end
  
  it "スレッドのキャッシュを削除" do
    board_dir = SpecSystem::SpecConfiguration.data_directory + "jbbs.livedoor.jp" + "category" + "123"
    (board_dir + "456.dat").should be_exist
    (board_dir + "456.index.marshal").should be_exist
    @request = TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/delete_cache")
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    @response.status_code.should == 303
    @response.headers["Location"].should == "../"
    (board_dir + "456.dat").should_not be_exist
    (board_dir + "456.index.marshal").should_not be_exist
  end
  
end



describe "2chのスレッドを読む" do
  require 'bbs2ch'
  include BBS2ch
  
  def view_thread(delta_input)
    @request = TwoB::Request.new("/server.2ch.net/board/123/l50#firstNew")
    @system = SpecSystem.new(@request)
    BBS2ch::Thread.__send__(:define_method, :get_new_input) do |request|
      delta_input
    end
    @system.process
    @response = @system.response
    @thread = @response.document
  end
  
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end
  
  def valid_thread(thread)
    thread.dat_link.attribute("href").text.should == "http://server.2ch.net/board/dat/123.dat"
    thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
  end
  
  it "キャッシュなしの初回読み込み" do
    SpecSystem.clear_cache_dir
    
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))

    valid_response

    thread = @response.document
    valid_thread(thread)
    thread[1].should be_exist
    thread[80].should be_new
    thread[81].should_not be_exist
    created_cache = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board" + "123.dat"
    created_cache.size.should == 24832
  end
  
  it "追加読み込み" do
    # TODO exampleの実行順序に依存しているので、順序を保障するか実行のし直しが必要
    view_thread(BinaryFile.by_filename("testData/2ch/example(81-100).dat"))

    valid_response

    thread = @response.document
    valid_thread(thread)
    thread[1].should_not be_new
    thread[50].should_not be_exist
    thread[80].should_not be_new
    thread[81].should be_new
    thread[100].should be_new
    thread[101].should_not be_exist
  end
  
  it "追加読み込みしたが新着が無かった" do
    view_thread(StringInput.empty)

    valid_response
    
    thread = @response.document
    valid_thread(thread)
    thread[1].should_not be_new
    thread[50].should_not be_exist
    thread[51].should_not be_new
    thread[100].should_not be_new
    thread[101].should_not be_exist
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
    board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
    (board_dir + "123.dat").should be_exist

    pending("BBS2chはインデックス未対応")
    (board_dir + "123.index.marshal").should be_exist
    @request = TwoB::Request.new("/server.2ch.net/board/123/delete_cache")
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    @response.status_code.should == 303
    @response.headers["Location"].should == "../"
    (board_dir + "123.dat").should_not be_exist
    (board_dir + "123.index.marshal").should_not be_exist
  end
  
end
