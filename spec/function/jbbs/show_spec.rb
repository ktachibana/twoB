require 'action'

describe "JBBSのshow" do
  include TwoB::Spec
  
  it "スレのオリジナルURLを受け取るとスレ表示画面へリダイレクトされる" do
    access("/show", {"url" => ["http://jbbs.livedoor.jp/bbs/read.cgi/computer/41116/1275477552/l50"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/jbbs.livedoor.jp/computer/41116/1275477552/l50#firstNew"}
  end

  it "板も同じく" do
    access("/show", {"url" => ["http://jbbs.livedoor.jp/computer/41116/"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/jbbs.livedoor.jp/computer/41116/"}
  end
end
