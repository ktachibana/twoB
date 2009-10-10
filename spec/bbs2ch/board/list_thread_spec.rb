require 'twob/board_handler'
require 'bbs2ch/board/board_stub'
require 'spec_base'
require 'source'
require 'board_view'

describe BBS2ch::Board, "list_thread" do
  include TwoB
  
  it "example" do
    FileUtils.rmtree("spec_cache")
    @system = SpecSystem.new
    @board = @system / "pc12.2ch.net" / "tech"
    @board.subject_source = TextFile.by_filename("testData/2ch/subject.txt", "CP932")
    
    view = @board.list_thread
    view.should be_kind_of(BoardView)
    view.board.should == BoardHandler::BoardInfo.new("http://pc12.2ch.net/tech/")
    view.threads.size.should == 711
    
    first_item = ThreadSubject::Item.new(1, "924090402", "■24時間即納！ すぐに使えるT-bananaサーバー ", 1)
    view.threads.first.should == ThreadSubject.new(first_item, 0)
    last_item = ThreadSubject::Item.new(711, "1189246532", "美しい国　派遣日本", 42)
    view.threads.last.should == ThreadSubject.new(last_item, 0)
  end
end
