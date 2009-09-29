# -*- coding: utf-8 -*-
require 'bbs2ch/thread/dat_parser'
require 'source'

describe BBS2ch::DatParser do
  it "parseできる" do
    source = TextFile.new("testData/2ch/2ch_with_id_short.dat", "CP932")
    parser = BBS2ch::DatParser.new
    dat = parser.parse(source)
    dat.res_list.size.should == 7

    res = dat.res_list.last
    res.should_not be_nil
    res.id.should == "GxtZ7C3e"
    res.date.should == "2008/11/07(金) 19:56:36"
    res.body.to_s.should =~ /\Aフォルダビューのウイジットの大きさを変更しようとしたら、/
  end
  
  it "部分的parse" do
    source = TextFile.new("testData/2ch/2ch_with_id.dat", "CP932")
    parser = BBS2ch::DatParser.new
    dat = parser.parse_parts(source, [DatPart.new(1, 0, 1), DatPart.new(100, 0x419c, 150)])
    dat.res_list.size.should == 52
    dat.res_list[0].number.should == 1
    dat.res_list[0].date.should == "2008/01/07(月) 14:10:06"
    dat.res_list[1].number.should == 100
    dat.res_list[1].date.should == "2008/01/17(木) 23:49:55"
    dat.res_list.last.number.should == 150
    dat.res_list.last.date.should == "2008/01/20(日) 02:15:26"
  end
end
