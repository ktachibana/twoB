# -*- coding: utf-8 -*-
require 'pathname'
require 'rexml/text'
require 'io/source'
require 'twob/board/subject'
require 'twob/board/subject_parser'

describe "JBBS SubjectParser" do
  before do
    @parser = TwoB::SubjectParser.new(/^(\d+)\.cgi,(.+)\((\d+)\)$/)
  end

  it "jbbs/jbs-subject.txtをparseできる" do
    subjects = @parser.parse(TextFile.by_filename("testData/jbbs/jbbs-subject.txt", "EUC-JP-MS"))

    subjects.size.should == 210
    subjects.first.should == TwoB::ThreadSubject::Item.new(1, "1205956389", "東方系同人 書店委託情報", 424)
    subjects[-2].should == TwoB::ThreadSubject::Item.new(209, "1205945052","チルノの裏　188crn", 1000)
  end

  it "subject.txtが壊れていてもとりあえずparseはできる" do
    subjects = @parser.parse(TextFile.by_filename("testData/jbbs/bug-subject.txt", "EUC-JP-MS"))

    subjects.size.should == 193

    bug_line = subjects.find{|item| item.number == "1230355047" }
    bug_line.res_count == 605
  end
end
