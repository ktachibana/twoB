# -*- coding: utf-8 -*-
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'
require 'action'

require 'jbbs/thread'

describe "JBBSのスレッドを読む" do
  include JBBS
  include TwoB::Spec
  
  def view_thread(delta_input, picker = "subscribe5")
    access("/jbbs.livedoor.jp/category/123/456/#{picker}#firstNew") do |system|
      system.stub!(:get_delta_input).and_return(delta_input)
    end
    valid_response
    @thread = @response.as_thread
  end
  
  before do
    SpecSystem.clear_cache_dir
    @example_1to216 = BinaryFile.by_filename("testData/jbbs/example(1-216).dat")
    @example_217to226 = BinaryFile.by_filename("testData/jbbs/example(217-226).dat")
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "jbbs.livedoor.jp" + "category" + "123"
  end
  
  it "キャッシュなしの初回読み込み" do
    view_thread(@example_1to216)

    thread = @response.as_thread
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should be_exist
    thread[216].should be_new
    thread[217].should_not be_exist
    created_cache = @board_dir + "456.dat"
    created_cache.size.should == 31178
  end
  
  it "追加読み込み" do
    view_thread(@example_1to216)
    view_thread(@example_217to226)

    thread = @response.as_thread
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread.res_ranges.should == [1..1, 212..226]
    thread[1].should_not be_new
    thread[216].should_not be_new
    thread[217].should be_new
    thread[226].should be_new
  end
  
  it "subscribe5によるキャッシュなしの初回読み込み" do
    view_thread(@example_1to216, "subscribe5")
    @response.as_thread.res_ranges.should == [1..216]
  end
  
  it "subscribe5による追加読み込み" do
    view_thread(@example_1to216, "subscribe5")
    view_thread(@example_217to226, "subscribe5")

    thread = @response.as_thread
    thread.res_ranges.should == [1..1, 212..226]
    thread[216].new?.should be_false
    thread[217].new?.should be_true
  end

  it "追加読み込みしたが新着が無かった" do
    view_thread(@example_1to216)
    view_thread(@example_217to226)
    view_thread(StringInput.empty)

    thread = @response.as_thread
    thread.dat_link.attribute("href").text.should == "http://jbbs.livedoor.jp/bbs/rawmode.cgi/category/123/456/"
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread.res_ranges.should == [1..1, 222..226]
    thread[1].should_not be_new
    thread[222].should_not be_new
    thread[226].should_not be_new
  end
  
  it "レスアンカー表示" do
    view_thread(@example_1to216)
    access("/jbbs.livedoor.jp/category/123/456/res_anchor", "range"=> ["10-20"])

    valid_response
    anchor = @response.as_thread
    anchor[9].should_not be_exist
    anchor[10].should be_exist
  end
  
  it "スレッドのキャッシュを削除" do
    view_thread(@example_1to216)
    
    (@board_dir + "456.dat").should be_exist
    (@board_dir + "456.yaml").should be_exist
    
    access("/jbbs.livedoor.jp/category/123/456/delete_cache")

    @response.status_code.should == 303
    @response.headers["Location"].should == "../"
    (@board_dir + "456.dat").should_not be_exist
    (@board_dir + "456.index.marshal").should_not be_exist
  end
  
end
