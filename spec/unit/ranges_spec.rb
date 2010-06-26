require 'util/ranges'

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
  
  it "union" do
    pending
    ranges = Ranges.union(1..3, 7..10, 4..6)
    ranges.should == [1..10]
  end
  
  it "union 2" do
    pending
    ranges = Ranges.union(7..10, 1..3, 4..6)
    ranges.should == [1..10]
  end

  describe "limit" do
    before do
      @ranges = Ranges.union(1..1, 100..200)
    end

    it "normal" do
      @ranges.limit(150).should == [1..1, 100..150]
    end

    it "範囲外" do
      @ranges.limit(90).should == [1..1]
    end

    it "変化なし" do
      @ranges.limit(300).should == [1..1, 100..200]
    end

    it "境界" do
      @ranges.limit(200).should == [1..1, 100..200]
      @ranges.limit(199).should == [1..1, 100..199]
    end
  end
end