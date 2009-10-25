# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/configuration'
require 'jbbs/thread/thread_service'
require 'spec_system'
require 'pathname'

include JBBS

describe ThreadService do
  before do
    @thread = SpecSystem.new() / Host::Name / "cat" / "012" / "345"
  end
  
  it do
    @thread.original_url.should == "http://jbbs.livedoor.jp/bbs/read.cgi/cat/012/345/"
  end
  
  it "readのexample" do
    @thread.stub!(:get_new_input).and_return(BinaryFile.by_filename("testData/jbbs/jbbs.dat"))
    
    view = @thread.read(Latest.new(50, true))
    
    view.thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
  end
end
