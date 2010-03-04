# -*- coding: utf-8 -*-
require 'util'
require 'io/source'
require 'io/http/http_request'
require 'io/input'
require 'encoder'
require 'net/http'
Net::HTTP.version_1_2

class HTTPGetSource < InputSource
  def initialize(request, encoder, line_delimiter)
    super(HTTPGetInput.new(request), encoder, line_delimiter)
  end
end

class HTTPGetInput
  include Input
  include Net
    
  def initialize(request)
    @request = request
  end
  
  def each_read
    HTTP.start(@request.host) do |http|
      http.request_get(@request.path, @request.headers) do |response|
        response.read_body do |data|
          yield data
        end
      end
    end
  end
end
