# -*- coding: utf-8 -*-
require 'jbbs/board/board_service'
require 'spec_system'

describe JBBS::BoardService do
  before do
    @system = SpecSystem.new()
    @host = JBBS::Host.new(@system)
    @category = JBBS::Category.new(@host, "cat")
    @board = JBBS::BoardService.new(@category, "012")
  end

  it do
    @board.original_url.should == "http://jbbs.livedoor.jp/cat/012/"
    @board.subject_url.should == "http://jbbs.livedoor.jp/cat/012/subject.txt"
  end
end
