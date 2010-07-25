require 'action'

describe "show" do
  include TwoB::Spec
  it "show() response" do
    access("/show", {"url" => ["http://pc12.2ch.net/test/read.cgi/tech/1264432017/l50"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/pc12.2ch.net/tech/1264432017/l50#firstNew"}
  end
end
