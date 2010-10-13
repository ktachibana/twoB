require 'action'

describe "2chのshow" do
  include TwoB::Spec
  it "スレのオリジナルURLを受け取るとスレ表示画面へリダイレクトされる" do
    access("/show", {"url" => ["http://pc12.2ch.net/test/read.cgi/tech/1264432017/l50"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/pc12.2ch.net/tech/1264432017/l50#firstNew"}
  end

  it "板も同じく" do
    access("/show", {"url" => ["http://pc12.2ch.net/tech/"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/pc12.2ch.net/tech/"}
  end
end
