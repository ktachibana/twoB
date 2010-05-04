# -*- coding: utf-8 -*-
require 'pathname'
require 'spec_system'
require 'io/source'
require 'twob/request'
require 'twob/thread'

describe "ResAnchor" do
  before do
    @path_info = "/jbbs.livedoor.jp/cat/012/345/res_anchor"
    @system = SpecSystem.new()
    @host = JBBS::Host.new(@system)
    @category = JBBS::Category.new(@host, "cat")
    @board = JBBS::BoardService.new(@category, "012")
    @thread = JBBS::ThreadService.new(@board, "345")
  end
  
  it do
    view = @thread.res_anchor(TwoB::Picker::Only.new(50))
    view.should be_kind_of(ResAnchorView)
    view.res_list.should be_kind_of(Array)
  end
end
