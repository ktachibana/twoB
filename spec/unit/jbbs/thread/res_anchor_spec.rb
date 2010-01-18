# -*- coding: utf-8 -*-
require 'pathname'
require 'spec_system'
require 'io/source'
require 'twob/request'
require 'twob/thread/bbs_thread'
require 'twob/thread/dat'

describe "ResAnchor" do
  before do
    @path_info = "/jbbs.livedoor.jp/cat/012/345/res_anchor"
    @system = SpecSystem.new()
    @host = JBBS::Host.new(@system)
    @category = JBBS::Category.new(@host, "cat")
    @board = JBBS::BoardService.new(@category, "012")
    @thread = JBBS::ThreadService.new(@board, "345")
    @request = TwoB::Request.new(@path_info, {"range" => ["50"]})
  end
  
  class MarshalerStub
    def initialize(object)
      @object = object
    end
    
    def load
      @object
    end
    
    def save(object)
      
    end
    
    def update
      
    end
  end
  
  it do
    dat_content = JBBS::DatParser.new().parse(TextFile.new(Pathname.new("testData/jbbs/jbbs.dat"), "EUC-JP"))
    res_list = dat_content.res_list.collect{|res| TwoB::Res.new(res, false, true) }
    
    view = @thread.execute(@request, "res_anchor")
    view.should be_kind_of(ResAnchorView)
    view.res_list.should be_kind_of(Array)
  end
end