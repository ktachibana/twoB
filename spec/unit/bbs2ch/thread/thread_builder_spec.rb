# -*- coding: utf-8 -*-
require 'twob/thread'
require 'bbs2ch/thread'

module BBS2ch
  class ThreadBuilder
    include TwoB::Dat
    DATE_PATTERN = /\A(.*?)( ID:(\S+))?( BE:(.*))?\z/

    def initialize(host_name, board_id, thread_id)
      @host_name = host_name
      @board_id = board_id
      @thread_id = thread_id
      
      @title = ""
      @caches = []
      @deltas = []
      @number = 1
      @last_res_number = 0
    end
    
    def build_delta(*dat_columns)
      eval_dat_line(dat_columns, @deltas)
    end
    
    def build_cache(*dat_columns)
      eval_dat_line(dat_columns, @caches)
    end
    
    def eval_dat_line(dat_columns, dat_lines)
      name_string = dat_columns.fetch(0, "")
      name_match = DatParser::TRIP_PATTERN.match(name_string)
      name = name_match ? name_match[1] : name_string
      trip = name_match ? name_match[3] : nil
      mail = dat_columns.fetch(1, "")
      date_id_be_string = dat_columns.fetch(2, "")
      date_match = DATE_PATTERN.match(date_id_be_string)
      date = date_match ? date_match[1] : ""
      id = date_match ? date_match[3] : nil
      be = date_match ? date_match[5] : nil
      body_text = dat_columns.fetch(3, "").lstrip
      
      @title = dat_columns.fetch(4, "") if dat_columns[4]
      dat_lines << BBS2ch::DatLine.new(@number, name, trip, mail, date, id, be, parse_body(body_text))
      @last_res_number = @number
      @number += 1
    end
    private :eval_dat_line
    
    attr_reader :title, :last_res_number
    
    def has_new?
      !@deltas.empty?
    end

    def get_thread
      self
    end
  end
end


include BBS2ch

describe ThreadBuilder do
  before do
    @builder = BBS2ch::ThreadBuilder.new("host_name", "board_id", "thread_id")
    @dat_columns = [
      "login:Penguin",
      "",
      "2008/01/07(月) 14:10:06 ID:T0OW3SHo",
      " KDE（K Desktop Environment）は、X Window Systemなどの上で動作するフリーソフトウェアのデスクトップ環境である・・・。 <br> " +
        " <br> " +
        "バージョン4のリリースを控えたKDEの明日はどっちだ！ <br> " +
        " <br> " +
        "【本家】 <br> " +
        "http://www.kde.org/ <br> " +
        "【日本KDEユーザ会】 <br> " +
        "http://www.kde.gr.jp/ <br> " +
        "【GUIライブラリQt】 <br> " +
        "http://www.trolltech.com/  ",
      "KDE スレッド7"]
  end
  
  it "example" do
    @builder.build_delta(*@dat_columns)

    thread = @builder.get_thread
    thread.last_res_number.should == 1
    thread.title.should == "KDE スレッド7"
    thread.should have_new
  end
  
  it "build from cache" do
    dat_columns2 = [
      "login:Penguin",
      "sage",
      "2008/01/07(月) 14:21:16 ID:Y+mA6iwW",
      " 過去スレ <br> " +
        " <br> " +
        "KDEスレ <br> " +
        "http://pc.2ch.net/linux/kako/983/983412433.html <br> " +
        "KDEスレ Part 2 <br> " +
        "http://pc.2ch.net/linux/kako/1007/10073/1007375984.html <br> " +
        "KDEスレ Part 3 <br> " +
        "http://pc.2ch.net/test/read.cgi/linux/1042006351/ <br> " +
        "KDEスレ Part 4 <br> " +
        "http://pc5.2ch.net/test/read.cgi/linux/1063215522/ <br> " +
        "KDEスレ Part 5 <br> " +
        "http://pc8.2ch.net/test/read.cgi/linux/1088074467/  <br> " +
        "KDEスレ　Part6 <br> " +
        "http://pc11.2ch.net/test/read.cgi/linux/1126775147/ ",
      ""]
    @builder.build_cache(*@dat_columns)
    thread = @builder.get_thread
    thread.title.should == "KDE スレッド7"
    thread.should_not have_new
  end
end
