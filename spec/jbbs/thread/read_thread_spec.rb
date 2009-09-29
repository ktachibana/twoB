# -*- coding: utf-8 -*-
require 'spec'
require 'source'
require 'twob/configuration'
require 'jbbs/thread/thread_service'
require 'spec_base'

describe JBBS::ThreadService do
  before do
    @system = SpecSystem.new()
    @host = JBBS::Host.new(@system)
    @category = JBBS::Category.new(@host, "cat")
    @board = JBBS::BoardService.new(@category, "012")
    @thread = JBBS::ThreadService.new(@board, "345")
  end
  
  it do
    @thread.original_url.should == "http://jbbs.livedoor.jp/bbs/read.cgi/cat/012/345/"
  end
end
