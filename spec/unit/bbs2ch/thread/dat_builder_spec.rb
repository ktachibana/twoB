require 'bbs2ch/thread'
require 'io'

module BBS2ch
  describe DatBuilder do
    before do
      @values =
      ["login:Penguin",
        "",
        "2009/03/01(日) 16:46:00 ID:xK7gFt2r",
        " KDE（K Desktop Environment）は、X Window Systemなどの上で動作する <br> フリーソフトウェアのデスクトップ環境。 <br>  <br> 【本家】 <br> http://www.kde.org/ <br> 【日本KDEユーザ会】 <br> http://www.kde.gr.jp/ <br> 【GUIライブラリQt】 <br> http://www.qtsoftware.com/ <br>",
        "KDEスレ Part 8"]
      @with_trip_values =
      ["foo bar </b>◆Zsh/ladOX. <b>",
        "sage",
        "2009/12/09(水) 01:07:25 ID:UxWjoMUQ",
        " Fedora12のKDE(バージョン4.3.3)なんですが、 <br> 以下のように壁紙を変更するところのサムネイルが <br> ちゃんと出ないのですが、何かパッケージが必要なのでしょうか、教えてください。 <br> http://nullpo.homeunix.net/~dia/diary/my_images/kde_plasma.jpg <br>  ",
        ""]
      @builder = BBS2ch::DatBuilder.new
    end

    it "build" do
      @builder.start(1)
      @builder.build(@values)

      dat = @builder.result
      dat.res_list.length.should == 1
      dat.title.should == "KDEスレ Part 8"

      res = dat.res_list.first
      res.number.should == 1
      res.name.should == "login:Penguin"
      res.mail.should == ""
      res.id.should == "xK7gFt2r"
      res.date.should == "2009/03/01(日) 16:46:00"
      res.body.to_s.should =~ /\AKDE（K Desktop Environment）は、/
    end

    it "トリップ付きbuild" do
      @builder.start(3)
      @builder.build(@with_trip_values)

      dat = @builder.result
      res = dat.res_list.first
      res.number.should == 3
      res.name.should == "foo bar"
      res.trip.should == "Zsh/ladOX."
    end

    it ">>10から>>14まで読み込み、フィルターで>>11-13のみを結果に含める" do
      @builder.start(10)
      5.times do
        @builder.build(@values){|res| (11..13).include?(res.number) }
      end
      dat = @builder.result
      dat.res_list.length == 3
      dat.res_list.first.number.should == 11
      dat.res_list.last.number.should == 13
    end
  end
end
