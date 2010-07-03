require 'bbs2ch/thread/dat_builder'
require 'io/file'

module BBS2ch
  describe DatBuilder do
    before do
      @values =
       ["login:Penguin",
        "",
        "2009/03/01(日) 16:46:00 ID:xK7gFt2r",
        " KDE（K Desktop Environment）は、X Window Systemなどの上で動作する <br> フリーソフトウェアのデスクトップ環境。 <br>  <br> 【本家】 <br> http://www.kde.org/ <br> 【日本KDEユーザ会】 <br> http://www.kde.gr.jp/ <br> 【GUIライブラリQt】 <br> http://www.qtsoftware.com/ <br>",  
        "KDEスレ Part 8"]
      @builder = BBS2ch::DatBuilder.new
    end
    
    it "build" do
      @builder.start(1)
      @builder.build(@values)
      dat = @builder.result
      dat.res_list.length.should == 1
      dat.res_list.first.number.should == 1
      dat.res_list.first.name.should == "login:Penguin"
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
