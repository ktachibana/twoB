require 'pathname'
require 'rexml/text'
require 'source'
require 'jbbs/board/subject_parser'

describe JBBS::BoardSubjectParser do
  it "バグっててもとりあえずparseはできる" do
    file = Pathname.new("testData/jbbs/bug-subject.txt")
    
    parser = JBBS::BoardSubjectParser.new()
    subjects = parser.parse(TextFile.new(file, "EUC-JP-MS"))

    subjects.size.should == 193
    bug_line = subjects.find{|item| item.number == "1230355047" }
    bug_line.res_count == 605
  endend
