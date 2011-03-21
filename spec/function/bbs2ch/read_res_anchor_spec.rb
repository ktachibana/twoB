# -*- coding: utf-8 -*-
require 'bbs2ch/all'
require 'nokogiri'
require 'io'
require 'bbs2ch/action'

describe "2chのレスアンカーを表示する" do
  include TwoB::Spec
  include BBS2ch
  include BBS2ch::Spec

  before do
    clear_cache_dir
  end

  it "1-3表示" do
    view_thread(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))
    view_res_anchor("1-3")

    valid_response

    thread = @response.as_thread
    thread.res_ranges.should == [1..3]
    thread[1].date.should == "2008/08/17(日) 15:30:19"
    thread[1].id.should == "1hlWO7Vt"
    thread[1].new?.should be_false
  end
end
