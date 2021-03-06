# -*- coding: utf-8 -*-
require 'io'
require 'http_get_input_stub'

describe HTTPGetInputStub do
  before do
    host = "www.spec-validation.com"
    port = 80
    path = "/construct"
    headers = {}
    @request = HTTPRequest.new(host, port, path, headers)
    @http = HTTPGetInputStub.new(@request)
  end

  it "requestを格納できる" do
    @http.request.should be_equal(@request)
  end

  it "each_read()は設定したsourceからデータを読み込む" do
    @http.response_source = StringSource.new("<html></html>")

    result = ""
    @http.each_read do |data|
      result << data
    end

    result.should == "<html></html>"
  end

end
