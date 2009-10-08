# -*- coding: utf-8 -*-
require 'encoder'

describe Encoder do
  it "使い方" do
    enc = Encoder.by_name("CP932")
    enc.open do
      enc.encode("")
    end
  end
end