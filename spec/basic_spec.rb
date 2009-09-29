# -*- coding: utf-8 -*-

describe String do
  it "部分文字列" do
    "bar"[1..-1].should == "ar"
  end
end

describe Array do
  before do
    @array = [10, 20]
  end

  it "fetch" do
    @array[2].should be_nil
  end
end
