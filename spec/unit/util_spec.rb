# -*- coding: utf-8 -*-
require 'util'

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

describe Ranges do
  it "接合するrangeは一つにまとめられる" do
    ranges = Ranges.union(1..2, 3..4, 10..20)
    ranges.should == [1..4, 10..20]
    ranges.empty?.should be_false
  end

  it "emptyなrangesも許容される" do
    ranges = Ranges.new
    ranges.should == []
    ranges.empty?.should be_true
  end

  describe "limit" do
    before do
      @ranges = Ranges.union(1..1, 100..200)
    end

    it "normal" do
      @ranges.limit(150).should == [1..1, 100..150]
      @ranges.limit_range(130..150).should == [130..150]
      Ranges.new(100..200, 400..500).limit_range(150..450).should == [150..200, 400..450]
    end

    it "範囲外" do
      @ranges.limit(90).should == [1..1]
      @ranges.limit_range(10..30).should == []
    end

    it "変化なし" do
      @ranges.limit(300).should == [1..1, 100..200]
      @ranges.limit_range(1..300).should == [1..1, 100..200]
    end

    it "境界" do
      @ranges.limit(200).should == [1..1, 100..200]
      @ranges.limit(199).should == [1..1, 100..199]
      @ranges.limit_range(1..200).should == [1..1, 100..200]
      @ranges.limit_range(2..199).should == [100..199]
    end

    it "反転" do
      Ranges.new(1..0, 200..100).limit_range(1..200).should == []
      Ranges.new(1..10, 100..200).limit_range(200..1).should == []
    end
  end
end
