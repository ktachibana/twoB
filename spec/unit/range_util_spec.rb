# -*- coding: utf-8 -*-
require 'util/range'

describe Range do
  it "adjacent_range?" do
    (1..3).adjacent_range?(4..6).should be_true
    (1..3).adjacent_range?(5..6).should be_false
    (4..6).adjacent_range?(1..3).should be_true
    (4..6).adjacent_range?(1..2).should be_false
    (1..10).adjacent_range?(4..5).should be_true
    (4..5).adjacent_range?(1..10).should be_true
    (4..6).adjacent_range?(5..10).should be_true
  end

  it "compose" do
    (1..3).compose(4..6).should == (1..6)
    (4..6).compose(1..3).should == (1..6)
  end
end
