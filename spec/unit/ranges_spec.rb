require 'util/ranges'

describe Ranges do
  it "接合するrangeは一つにまとめられる" do
    ranges = Ranges.new(1..2, 3..4, 10..20)
    ranges.to_a.should == [1..4, 10..20]
    ranges.empty?.should be_false
  end

  it "emptyなrangesも許容される" do
    ranges = Ranges.new()
    ranges.to_a.should == []
    ranges.empty?.should be_true
  end

  describe "limitation" do
    before do
      @ranges = Ranges.new(1..1, 100..200)
    end

    it "normal" do
      @ranges.limitation(150).should == [1..1, 100..150]
    end

    it "範囲外" do
      @ranges.limitation(90).should == [1..1]
    end

    it "変化なし" do
      @ranges.limitation(300).should == [1..1, 100..200]
    end

    it "境界" do
      @ranges.limitation(200).should == [1..1, 100..200]
      @ranges.limitation(199).should == [1..1, 100..199]
    end
  end
end