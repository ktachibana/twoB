require 'action'

describe "start page" do
  include TwoB::Spec

  it "リクエスト時のSCRIPT_NAMEが反映される" do
    access("/", {})
    doc = @response.as_document
    doc.xpath("//a[@class='bookmarklet']").attr("href").text.should == "javascript:location.href='http://192.168.0.6/twoB/script.rb/show?url=\'+encodeURI(location.href)"
    doc.xpath("//form").attr("action").text.should == "/twoB/script.rb/show"
  end
end
