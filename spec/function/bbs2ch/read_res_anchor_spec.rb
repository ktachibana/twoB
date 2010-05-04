# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'nokogiri'
require 'io'
require 'spec_system'
require 'pp'
require 'action'

describe "2chのレスアンカーを表示する" do
  include BBS2ch
  include BBS2ch::Spec
  
  before do
    SpecSystem.clear_cache_dir
  end
  
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end
  
  it "1-3表示" do
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))
    view_res_anchor("1-3")
    
    valid_response

    thread = @response.as_thread
    thread.res_ranges.should == [1..3]
    thread[1].date.should == "2008/08/17(日) 15:30:19"
    thread[1].id.should == "1hlWO7Vt"
  end
end
