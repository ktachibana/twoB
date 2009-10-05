# -*- coding: utf-8 -*-
require 'spec'
require 'source'
require 'jbbs/thread/dat_parser'

describe '管理者削除などにより、行が消失する場合がある' do
  it '行が抜けて、最終レス番が全レス数とずれている' do
    file = TextFile.new("testData/jbbs/unmatch-count-dat.txt", "euc-jp-ms")
    dat = JBBS::DatParser.new().parse(file)
    dat.res_list[-1].number == 251
    dat.res_list.size.should == 235
  end
end
