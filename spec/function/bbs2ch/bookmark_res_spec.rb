# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'
require 'bbs2ch/action'

describe "栞機能" do
  include BBS2ch
  
  before do
    SpecSystem.clear_cache_dir
    @test_data_dir = Pathname.new("testData/2ch")
    @example_1to80 = BinaryFile.new(@test_data_dir + "example(1-80).dat")
    @example_80to100 = BinaryFile.new(@test_data_dir + "example(81-100).dat")
    @example_subject = TextFile.new(@test_data_dir + "example-subject.txt", "Windows-31J")
  end
  
  def valid_thread(thread)
    thread.dat_link.attribute("href").text.should == "http://server.2ch.net/board/dat/123.dat"
    thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
  end
  
  it ">>80までを読み込んで>>10に栞" do
    view_thread(@example_1to80)
    valid_response
    bookmark_res(10)
    @response.status_code.should == 303
    
    view_thread(@example_1to80)
    @thread.res_ranges.should == [1..1, 10..80]
    @thread[10].new?.should be_true
  end
end
