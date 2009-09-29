# -*- coding: utf-8 -*-
require 'enum_util'
require 'source'
require 'encoder'
require 'net/http'
Net::HTTP.version_1_2


class HTTPGetSource < InputSource
  def initialize(host, path, headers, encoder, line_delimiter)
    super(HTTPGetInput.new(host, path, headers), encoder, line_delimiter)
  end
end

class HTTPGetInput
  def initialize(host, path, headers)
    @host = host
    @path = path
    @headers = headers
  end
  
  def read
    result = ""
    each_read do |data|
      result << data
    end
    result
  end
  
  def each_read
    Net::HTTP.start(@host) do |http|
      http.request(Net::HTTP::Get.new(@path, @headers)) do |response|
        response.read_body do|data|
          yield data
        end
      end
    end
  end
end
