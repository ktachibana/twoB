# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/configuration'
require 'jbbs/host'
require 'jbbs/thread/thread_service'
require 'spec_system'
require 'pathname'

include JBBS

describe ThreadService do
  before do
    @system = SpecSystem.new
    @thread = @system / JBBS::Host::Name / "cat" / "012" / "345"
  end
  
  it do
    @thread.original_url.should == "http://jbbs.livedoor.jp/bbs/read.cgi/cat/012/345/"
  end
  
  it "readのexample" do
    @system.stub!(:get_delta_input).and_return(BinaryFile.by_filename("testData/jbbs/jbbs.dat"))
    
    view = @thread.read(Subscribe.new(50))
    
    view.thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
  end
end

