# -*- coding: utf-8 -*-
require 'twob/handler'
require 'twob/system'
require 'twob/configuration'
require 'jbbs/thread/thread_service'
require 'jbbs/board/board_service'
require 'delegate'

describe TwoB::Handler do
  before do
    @system = TwoB::System.new(TwoB::Configuration.new(Pathname.new("2bcache")))
  end

  it "対応するハンドラが無いときはエラー" do
    lambda{ @system / "foo" }.should raise_error
    lambda{ @system / "jbbs.livedoor.jp" / "category" / "123" / "12345" / "10" / "foo" }.should raise_error
  end
  
  it "get_child and execute" do
    category = @system / JBBS::Host::Name / "cat"
    category.should be_kind_of(JBBS::Category)
    category.host.name.should == JBBS::Host::Name
    category.name.should == "cat"
    
    board = category / "123"
    def board.list_thread()
      @called = true
    end
    board.execute(nil, "")
    board.instance_variable_get(:@called).should be_true
    
    thread = board / "456"
    def thread.read(range)
      @called = true
      @range = range
    end
    thread.execute(nil, "10-20")
    thread.should be_kind_of(JBBS::ThreadService)
    thread.number.should == "456"
    thread.instance_variable_get(:@called).should be_true
    thread.instance_variable_get(:@range).should == TwoB::Picker::FromTo.new(10..20)
  end
  
  it "with #fragment" do
    request = TwoB::Request.new("jbbs.livedoor.jp/cat/123/12345/l50#fragment")
    request.path_info.should == "jbbs.livedoor.jp/cat/123/12345/l50"
    request.fragment.should == "fragment"
  end
  
  it "get board" do
    board = @system / "jbbs.livedoor.jp" / "cat" / "11223"
    board.original_url.should == "http://jbbs.livedoor.jp/cat/11223/"
    board.subject_url.should == "http://jbbs.livedoor.jp/cat/11223/subject.txt"
  end

  it "get thread" do
    thread = @system / "jbbs.livedoor.jp" / "category" / "123" / "12345"
    thread.should be_kind_of(JBBS::ThreadService)
  end
  
  it "get res anchor" do
    res_anchor = @system / "jbbs.livedoor.jp" / "category" / "123" / "3456"
    view = res_anchor.res_anchor(TwoB::Picker::FromTo.new(10..20))
    view.should be_kind_of(ResAnchorView)
  end
end
