# -*- coding: utf-8 -*-
require 'source'
require 'uri'

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

describe URI do
  it "相対パスの解決" do
    uri = URI.parse("http://www.host.jp/path/") + "../rel"
    uri.should == URI.parse("http://www.host.jp/rel")
  end
end

describe StringSource do
  before do
    @source = StringSource.new("10\n20\n30\n")
  end

  it "eachできる" do
    result = []
    @source.each{|line|
      result << line
    }
    result.should == ["10", "20", "30"]
  end

  it "collectできる" do
    @source.collect{|line| line.to_i }.should == [10, 20, 30]
  end
end

