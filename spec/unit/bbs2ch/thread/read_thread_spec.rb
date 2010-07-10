# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'twob/configuration'
require 'io/source'
require 'spec_system'
require 'pathname'

include BBS2ch

describe ThreadService do
  before do
    SpecSystem.clear_cache_dir()
    @system = SpecSystem.new
    @thread = @system / "foo.2ch.net" / "board" / "123"
  end
  
  it do
    @thread.original_url.should == "http://foo.2ch.net/test/read.cgi/board/123/"
  end
  
  it "read" do
    @thread.cache_file.should_not be_exist
    @system.stub!(:get_delta_input).and_return(BinaryFile.by_filename("testData/2ch/example(1-80).dat"))
    
    view = @thread.read(Subscribe.new(5))
    @thread.cache_file.should be_exist
    
    view.thread.title.should == "（　＾＾ω）ﾎﾏﾎﾏ6"
    
  end
end

