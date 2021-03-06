# -*- coding: utf-8 -*-
require 'twob/dat'

describe "dat_body objects" do
  def anchor(range)
    TwoB::Dat::Anchor.new(range)
  end

  it do
    anchor(">>10").range.should == (10..10)
    anchor(">>10-20").range.should == (10..20)
    anchor(">>20-10").range.should == (10..20)
  end
end
