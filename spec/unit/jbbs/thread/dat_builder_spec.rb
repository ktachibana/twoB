require 'jbbs/thread/dat_builder'

module JBBS
  describe DatBuilder do
    before do
      @values =
      ["1",
        "凜　</b> ◆Wpuzura65A<b>",
        "",
        "2008/04/12(土) 01:36:13",
        "いわゆる管理スレ。<br>何かあれば適当にどうぞ。",
        "鶉の羽の下（管理運営・意見・要望など）の7.5",
        "YL0bGuuo0"]
      @builder = JBBS::DatBuilder.new
    end

    it "build" do
      @builder.start(1)
      @builder.build(@values)
      dat = @builder.result
      dat.res_list.length.should == 1
      dat.res_list.first.number.should == 1
      dat.res_list.first.name.should == "凜　"
      dat.res_list.first.trip.should == "Wpuzura65A"
    end

    it ">>10から>>14まで読み込み、フィルターで>>11-13のみを結果に含める" do
      @builder.start(10)
      (10..14).each do |i|
        values = @values.dup
        values[0] = i.to_s
        @builder.build(values){|res| (11..13).include?(res.number) }
      end
      dat = @builder.result
      dat.res_list.length == 3
      dat.res_list.first.number.should == 11
      dat.res_list.last.number.should == 13
    end
  end
end
