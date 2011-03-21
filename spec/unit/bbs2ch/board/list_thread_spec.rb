require 'twob/board'
require 'spec_context'
require 'io'
require 'bbs2ch/all'

describe BBS2ch::Board do
  include TwoB
  include TwoB::Spec
  include BBS2ch

  it "list_thread" do
    clear_cache_dir
    backend = TwoB::Spec::SpecBackend.new
    backend.stub!(:get_subject_source).and_return{ TextFile.by_filename("testData/2ch/subject.txt", "Windows-31J") }
    @board = Board.new(Host.new(RootHandler.new(configuration, backend), "pc12.2ch.net"), "tech")

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
