require 'action'

describe "show" do
  include TwoB::Spec
  it "show() response" do
    access("/show", {"url" => ["http://jbbs.livedoor.jp/bbs/read.cgi/computer/41116/1275477552/l50"]})
    @response.status_code.should == 303
    @response.headers.should == {"Location" => "/twoB/action/jbbs.livedoor.jp/computer/41116/1275477552/l50#firstNew"}
  end
end
