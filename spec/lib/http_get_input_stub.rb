# -*- coding: utf-8 -*-
require 'io'

class HTTPGetInputStub
  def initialize(request)
    @request = request
    @response_source = StringSource.empty
  end
  attr :request
  attr_accessor :response_source

  def each_read
    @response_source.each do |line|
      yield line
    end
  end
end
