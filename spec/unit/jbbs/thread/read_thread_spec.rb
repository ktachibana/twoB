# -*- coding: utf-8 -*-
require 'jbbs/thread'
require 'jbbs/host'
require 'spec_context'

describe JBBS::ThreadService do
  include TwoB::Spec
  before do
    @thread = root / JBBS::Host::Name / "cat" / "012" / "345"
  end

  it do
    @thread.original_url.should == "http://jbbs.livedoor.jp/bbs/read.cgi/cat/012/345/"
  end
end

