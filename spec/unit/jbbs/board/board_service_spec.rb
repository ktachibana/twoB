# -*- coding: utf-8 -*-
require 'jbbs/board/board_service'
require 'spec_context'

describe JBBS::BoardService do
  include TwoB::Spec

  before do
    @board = root / JBBS::Host::Name / "cat" / "012"
  end

  it do
    @board.original_url.should == "http://jbbs.livedoor.jp/cat/012/"
    @board.subject_url.should == "http://jbbs.livedoor.jp/cat/012/subject.txt"
  end
end
