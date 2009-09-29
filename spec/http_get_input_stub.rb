# -*- coding: utf-8 -*-
$: << "../src"
require 'test/unit'
require 'pathname'
require 'equality'
require 'http_request'
require 'source'

include Test::Unit

class HTTPGetInputStub
  def initialize(request)
    @request = request
    @response_source = StringSource.new
  end
  attr :request
  attr_accessor :response_source
  
  def each_read
    @response_source.each do |line|
      yield line
    end
  end
end

class HTTPGetInputStubTest < TestCase
  def setup
    host = "www.spec-validation.com"
    path = "/construct"
    headers = {}
    @request = TwoB::HTTPRequest.new(host, path, headers)
    @http = HTTPGetInputStub.new(@request)
  end
  
  def test_store_request
    assert_equal(@request, @http.request)
  end

  def test_each_read_method_readable_configured_string
    @http.response_source = StringSource.new("<html></html>")

    result = ""
    @http.each_read do |data|
      result << data
    end
    
    assert_equal("<html></html>", result)
  end
  
  def test_each_read_method_readable_configured_file
    @http.response_source = TextFile.new("sample.txt", "UTF-8")
    
    result = []
    @http.each_read do |data|
      result << data
    end
    
    assert_equal(["sample", "text", "data"], result)
  end
  
end
