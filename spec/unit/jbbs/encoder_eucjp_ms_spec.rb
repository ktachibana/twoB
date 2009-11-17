# -*- coding: utf-8 -*-
require 'encoder'

describe Encoder do
  before do
    @euc = File.read("testData/jbbs/euc-jp-ms.dat")
    @from_euc = Encoder.by_name("euc-jp-ms")
  end
  
  it "Windows機種依存文字も正常に変換できる" do
    @from_euc.encode(@euc).should == "⑨Ⅳ"
  end
end
