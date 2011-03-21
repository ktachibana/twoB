# -*- coding: utf-8 -*-
require 'spec'
require 'twob/picker'

include TwoB
include TwoB::Picker

describe PatternMap do
  it "" do
    FooMap = PatternMap.new
    FooMap.map(/fo+/){|match, arg| [match[0], arg]}

    FooMap.get("foooo").should == ["foooo", nil]
    FooMap.get("foo", 10).should == ["foo", 10]
    FooMap.get("faa").should be_nil

    FooMap.unmatched { raise "error!" }
    lambda{ FooMap.get("faa") }.should raise_error(RuntimeError, "error!")
  end
end

describe Pickers do
  describe Subscribe do
    it "基本" do
      subscribe = Subscribe.new(10)
      subscribe.to_s.should == "subscribe10"
      subscribe.should == Subscribe.new(10)
    end

    it "subscribeNがSubscribeのフォーマット" do
      subscribe = Pickers.get("subscribe5")
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

    it "l10n" do
      l10n = Latest.new(10, false)
      l10n.to_ranges(0, 10).should == [1..10]
      l10n.to_ranges(0, 11).should == [2..11]
    end

    it "l10" do
      l10 = Latest.new(10, true)
      l10.to_ranges(0, 11).should == [1..11]
      l10.to_ranges(0, 12).should == [1..1, 3..12]
      l10.to_ranges(0, 10).should == [1..10]
    end
  end

  describe All do
    it "All pattern" do
      Pickers.get("").class.should == All
    end

    it "to_ranges" do
      All.instance.to_ranges(0, 10).should == [1..10]
    end
  end

  describe Only do
    it "Only pattern" do
      Pickers.get("10").class.should == Only
    end

    it ">>10のみ" do
      Only.new(10).to_ranges(0, 10).should == [10..10]
    end
  end

  describe FromTo do
    it "FromTo pattern" do
      Pickers.get("100-200").class.should == FromTo
    end

    it " to_ranges" do
      FromTo.new(5..10).to_ranges(0, 10).should == [5..10]
    end
  end

  describe From do
    it do
      From.new(10).should == From.new(10, true)
    end

    it "From pattern" do
      Pickers.get("3-").should == From.new(3, true)
      Pickers.get("3n-").should == From.new(3, false)
    end

    it "to_s" do
      From.new(10, true).to_s.should == "10-"
      From.new(10, false).to_s.should == "10n-"
    end

    it "to_ranges" do
      From.new(5).to_ranges(0, 10).should == [1..1, 5..10]
    end

    it "nを付けると>>1は含まれなくなる" do
      Pickers.get("47-").to_ranges(0, 100).should == [1..1, 47..100]
      Pickers.get("47n-").to_ranges(0, 100).should == [47..100]
    end

    it "build_thread" do
      builder = mock(:ThreadBuilder)
      builder.should_receive(:cached_number).and_return(100)
      builder.should_receive(:load_cache).with(1..1, 47..100)
      builder.should_receive(:load_delta)
      Pickers.get("47-").build_thread(builder)
    end
  end

  describe To do
    it "To pattern" do
      Pickers.get("-999").class.should == To
    end

    it "to_ranges" do
      To.new(5).to_ranges(0, 10).should == [1..5]
      To.new(5).to_ranges(0, 4).should == [1..5]
    end
  end

  it "Illegal format" do
    lambda { Pickers.get("foo") }.should raise_error(RuntimeError, /Illegal picker format : foo/)
  end
end
