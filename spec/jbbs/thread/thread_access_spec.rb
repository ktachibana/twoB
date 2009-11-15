# -*- coding: utf-8 -*-
require 'spec_system'
require 'twob/request'
require 'io/file'
require 'nokogiri'

describe "JBBSのスレッドを読む" do
  include JBBS
  
  def process(delta_input)
    @request = TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/l50#firstNew", {})
    @system = SpecSystem.new(@request)
    ThreadService.__send__(:define_method, :get_new_input) do |picker|
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
    
    process(BinaryFile.by_filename("testData/jbbs/example(1-216).dat"))
    
    valid_response

    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should be_exist
    thread[216].should be_new
    thread[217].should_not be_new
    created_cache = SpecSystem::SpecConfiguration.data_directory + "jbbs.livedoor.jp" + "category" + "123" + "456.dat"
    created_cache.size.should == 31178
  end
  
  it "追加読み込み" do
    # TODO exampleの実行順序に依存しているので、順序を保障するか実行のし直しが必要
    process(BinaryFile.by_filename("testData/jbbs/example(217-226).dat"))

    valid_response

    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should_not be_new
    thread[217].should be_exist
    thread[226].should be_exist
    thread[227].should_not be_exist
  end
  
  it "追加読み込みしたが新着が無かった" do
    process(StringInput.empty)

    valid_response
    
    thread = @response.document
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should_not be_new
    thread[226].should_not be_new
    thread[227].should_not be_exist
  end
end
