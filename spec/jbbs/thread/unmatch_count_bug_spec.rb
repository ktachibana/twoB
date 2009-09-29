require 'spec'
require 'source'
require 'jbbs/thread/dat_parser'

describe 'レス数が合わない事がある件について' do
  it 'parseしてみる' do
    file = TextFile.new("testData/jbbs/unmatch-count-dat.txt", "euc-jp-ms")
    dat = JBBS::DatParser.new().parse(file)
    dat.res_list[-1].number == 251
    dat.res_list.size.should == 235  end
end
