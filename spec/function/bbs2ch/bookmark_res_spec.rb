# -*- coding: utf-8 -*-
require 'io'
require 'spec_context'
require 'action'
require 'bbs2ch/action'
require 'yaml'

describe "栞機能" do
  include BBS2ch
  include BBS2ch::Spec
  include TwoB::Spec

  before do
    clear_cache_dir
    @test_data_dir = Pathname.new("testData/2ch")
    @example_1to80 = BinaryFile.new(@test_data_dir + "example(1-80).dat")
  end

  def valid_thread(thread)
    thread.dat_link.attribute("href").text.should == "http://server.2ch.net/board/dat/123.dat"
    thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
  end

  it ">>80までを読み込んで>>50に栞" do
    view_thread(@example_1to80)
    valid_response

    bookmark_res(50)
    @response.status_code.should == 303
    metadata_file = data_path + "server.2ch.net/board/123.yaml"
    metadata = YAML::load_file(metadata_file)
    metadata.bookmark_number.should == 50
    metadata.last_res_number.should == 80

    view_thread(StringInput.empty)
    @thread.res_ranges.should == [1..1, 46..80]
    @thread[50].new?.should be_false
    @thread[51].new?.should be_true
  end

  it ">>80までを読み込んで>>10に栞" do
    view_thread(@example_1to80)
    valid_response

    bookmark_res(10)
    @response.status_code.should == 303
    metadata_file = data_path + "server.2ch.net/board/123.yaml"
    metadata = YAML::load_file(metadata_file)
    metadata.bookmark_number.should == 10
    metadata.last_res_number.should == 80

    view_thread(StringInput.empty)
    @thread.res_ranges.should == [1..1, 6..80]
    @thread[10].new?.should be_false
    @thread[11].new?.should be_true
  end
end
