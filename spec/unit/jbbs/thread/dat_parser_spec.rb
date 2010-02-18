# -*- coding: utf-8 -*-
require 'twob/thread/dat/dat_body'
require 'jbbs/thread/dat_parser'

include TwoB
include Dat

describe JBBS::DatParser do
  before do
    @parser = JBBS::DatParser.new
  end

  def parse(dat_string)
    @parser.parse_delta(StringSource.new(dat_string))
  end

  it "parseできる" do
    dat_string = <<EOS
1<>凜　</b> ◆Wpuzura65A<b><><>2008/04/12(土) 01:36:13<>いわゆる管理スレ。<br>何かあれば適当にどうぞ。<>鶉の羽の下（管理運営・意見・要望など）の7.5<>YL0bGuuo0
2<>種族：名無し　多様性：高<>sage<>2008/04/12(土) 01:36:35<>移転乙です<><>a/E8tHkU0
3<>種族：名無し　多様性：高<>sage<>2008/04/12(土) 01:37:29<>お疲れ様です<><>F1ftygNkO
EOS

    dat = parse(dat_string)
    dat.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    dat.res_list.length.should == 3
    res1 = dat.res_list[0]
    res1.number.should == 1
    res1.name.should == "凜　"
    res1.has_trip?.should be_true
    res1.trip.should == "Wpuzura65A"
    res1.mail.should == ""
    res1.age?.should be_true
    res1.date.should == "2008/04/12(土) 01:36:13"
    res1.body.length.should == 3
    res1.body[0].to_s.should == "いわゆる管理スレ。"
    res1.body[1].body_type == :break_line
    res1.body[2].to_s.should == "何かあれば適当にどうぞ。"
    res1.id.should == "YL0bGuuo0"
    res2 = dat.res_list[1]
    res2.has_trip?.should be_false
  end

  it "アンカー含むbody" do
    dat_string = <<EOS
2<>no name<>mail<>date<>before<a href="/bbs/read.cgi/game/42679/1207931773/23-24" target="_blank">&gt;&gt;23-24</a>after<><>idididid
EOS
    body = parse(dat_string).res_list[0].body
    body.length.should == 3
    body[0].to_s.should == "before"
    body[1].to_s.should == ">>23-24"
    body[2].to_s.should == "after"
  end

  it "自動リンク認識" do

    dat_string = <<EOS
1<>no name<>mail<>date<>ahttp://host.com/path<br>foo<><>idididid
2<>no name<>mail<>date<>あttp://host2.com/path<><>idididid
3<>no name<>mail<>date<>tp://host3.com/path tp://host3.com/path<><>idididid
4<>no name<>mail<>date<>(ttp://host4.com/)<><>idididid
EOS
    res = parse(dat_string).res_list
    res[0].body.should ==
    [Text.new("a"),
      Link.new("http://host.com/path", "http://host.com/path"),
      BreakLine.new,
      Text.new("foo")]
    res[1].body.should ==
    [Text.new("あ"),
      Link.new("ttp://host2.com/path", "http://host2.com/path")]
    res[2].body.should ==
    [Link.new("tp://host3.com/path", "http://host3.com/path"),
      Dat::Text.new(" "),
      Link.new("tp://host3.com/path", "http://host3.com/path")]
    res[3].body.should ==
    [Dat::Text.new("("), Link.new("ttp://host4.com/", "http://host4.com/"), Text.new(")")]
  end

  it "'sage'だけでなく'sage'が含まれていればいいらしい" do
    dat = <<EOS
1<>no name<>foo sage<>date<>ahttp://host.com/path<br>foo<><>idididid
2<>no name<>sage foo<>date<>ahttp://host.com/path<br>foo<><>idididid
3<>no name<>sag e<>date<>ahttp://host.com/path<br>foo<><>idididid
EOS
    res = parse(dat).res_list
    res[0].age?.should be_false
    res[1].age?.should be_false
    res[2].age?.should be_true
  end

  it "部分的parse" do
    parser = JBBS::DatParser.new
    dat_string = <<EOS
1<>one<>mail<>date<>a<><>idididid
2<>two<>mail<>date<>あ<><>idididid
3<>three<>mail<>date<>foo<><>idididid
4<>four<>mail<>date<>bar<><>idididid
5<>five<>mail<>date<>b<><>idididid

EOS
    source = StringSource.new(dat_string)
    parts = [Dat::Part.new(1, 0, 1), Dat::Part.new(3, dat_string.index("3<>"), 4)]
    parser.parse_parts(source, parts)
    res_list = parser.get_dat_content.res_list
    res_list.collect{|res| res.name }.should == ["one", "three", "four"]
  end

  it "ファイルの実物から部分的parse" do
    parser = JBBS::DatParser.new
    source = TextFile.new("testData/jbbs/jbbs.dat", "euc-jp")
    parts = [Dat::Part.new(1, 0, 1), Dat::Part.new(100, 0x3773, 150)]
    parser.parse_parts(source, parts)
    res_list = parser.get_dat_content.res_list
    res_list.size.should == 52
    res_list[1].number.should == 100
    res_list[1].date.should == "2008/04/12(土) 19:04:51"
    res_list.last.number.should == 150
    res_list.last.date.should == "2008/04/13(日) 00:01:07"
  end
end
