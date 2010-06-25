# -*- coding: utf-8 -*-
require 'spec'
require 'pattern_map'
require 'twob/thread/picker'

include TwoB
include TwoB::Picker

describe PatternMap do
  it "" do
    FooMap = PatternMap.new
    FooMap.map(/fo+/){|match, arg| [match[0], arg]}

    FooMap.get("foooo").should == ["foooo", nil]
    FooMap.get("foo", 10).should == ["foo", 10]
    lambda{ FooMap.get("faa") }.should raise_error(RuntimeError)
  end
end

describe Pickers do
  describe Composite do
    it "compose" do
      composite = Composite.compose(1..2, 3..4, 10..20)
      composite.ranges.should == [1..4, 10..20]
      composite.empty?.should be_false
    end
    
    it "emptyなCompositeも許容される" do
      composite = Composite.compose()
      composite.ranges.should == []
      composite.empty?.should be_true
    end
    
    describe "limitation" do
      composite = Composite.compose(1..1, 100..200)
      
      it "normal" do
        composite.limitation(150).ranges.should == [1..1, 100..150]
      end
      
      it "範囲外" do
        composite.limitation(90).ranges.should == [1..1]
      end
      
      it "変化なし" do
        composite.limitation(300).ranges.should == [1..1, 100..200]
      end
      
      it "境界" do
        composite.limitation(200).ranges.should == [1..1, 100..200]
        composite.limitation(199).ranges.should == [1..1, 100..199]
      end
    end
  end
  
  describe Subscribe do
    it "subscribe+nがSubscribeのフォーマット" do
      subscribe = Pickers.get("subscribe+5")
      subscribe.class.should == Subscribe
      subscribe.cache_count.should == 5
    end

    it "キャッシュ>>10まで、新着>>20までのとき" do
      subscribe = Subscribe.new(5)
      subscribe.to_ranges(10, 20).should == [1..1, 6..20]
      subscribe.to_cache_ranges(10, 20).should == [1..1, 6..10]
    end
  end

  describe Latest do
    it "Latest pattern" do
      l50 = Pickers.get("l50")
      l50.class.should == Latest
      l50.include_1.should be_true
    end
  
    it "Latest pattern without 1" do
      l50n = Pickers.get("l50n")
      l50n.should be_kind_of(Latest)
      l50n.include_1.should be_false
    end
    
    it "include_range?" do
      l10n = Latest.new(10, false)
      l10n10 = l10n.concretize(0, 10)
      l10n10.include_range?(1..1).should be_true
      l10n10.include_range?(1..2).should be_true
      l10n10.include_range?(2..2).should be_true
      l10n10.include_range?(1..11).should be_false
      
      l10n11 = l10n.concretize(0, 11)
      l10n11.include_range?(1..1).should be_false
      l10n11.include_range?(1..2).should be_false
  
      l10 = Latest.new(10, true)
      l10_11 = l10.concretize(0, 11)
      l10_11.include_range?(1..1).should be_true
      l10_11.include_range?(1..2).should be_true
      
      l10_10 = l10.concretize(0, 10)
      l10_10.include_range?(2..2).should be_true
      
      l10_12 = l10.concretize(0, 12)
      l10_12.include_range?(1..1).should be_true
      l10_12.include_range?(1..2).should be_false
      l10_12.include_range?(1..3).should be_false
      l10_12.include_range?(2..2).should be_false
      l10_12.include_range?(3..3).should be_true
    end
  end

  describe All do
    it "All pattern" do
      Pickers.get("").class.should == All
    end
    
    it "include_range?" do
      All.instance.concretize(0, 10).include_range?(1..10).should be_true
      All.instance.concretize(0, 10).include_range?(11..11).should be_false
    end
  end
  
  describe Only do
    it "Only pattern" do
      Pickers.get("10").class.should == Only
    end
    
    it "include_range?" do
      Only.new(10).concretize(0, 10).include_range?(10..10).should be_true
      Only.new(10).concretize(0, 10).include_range?(9..10).should be_false
    end
  end
  
  describe FromTo do
    it "FromTo pattern" do
      Pickers.get("100-200").class.should == FromTo
    end
    
    it " include_range?" do
      FromTo.new(5..10).concretize(0, 10).include_range?(5..10).should be_true
      FromTo.new(5..10).concretize(0, 10).include_range?(5..11).should be_false
    end
  end
  
  describe From do
    it "From pattern" do
      Pickers.get("3-").class.should == From
    end
  
    it "include_range?" do
      From.new(5).concretize(0, 10).include_range?(5..10).should be_true
      From.new(5).concretize(0, 10).include_range?(5..11).should be_false
    end
  end
  
  describe To do
    it "To pattern" do
      Pickers.get("-999").class.should == To
    end
  
    it "include_range?" do
      To.new(10).concretize(0, 10).include_range?(10..10).should be_true
      To.new(10).concretize(0, 10).include_range?(10..11).should be_false
    end
  end
  
  it "Illegal format" do
    lambda { Pickers.get("foo") }.should raise_error(RuntimeError)
  end
end
