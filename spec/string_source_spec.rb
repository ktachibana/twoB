# -*- coding: utf-8 -*-
require 'io/string'

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

