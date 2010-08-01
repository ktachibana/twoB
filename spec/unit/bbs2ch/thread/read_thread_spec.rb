# -*- coding: utf-8 -*-
require 'bbs2ch'
require 'spec_context'

describe BBS2ch::ThreadService do
  include TwoB::Spec
  before do
    @thread = root / "foo.2ch.net" / "board" / "123"
  end

  it do
    @thread.original_url.should == "http://foo.2ch.net/test/read.cgi/board/123/"
  end
end

