# -*- coding: utf-8 -*-
$: << "../src"
require 'source'

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
