# -*- coding: utf-8 -*-
require 'equality'

class HTTPRequest
  def initialize(host, port, path, headers)
    @host = host
    @port = port
    @path = path
    @headers = headers
  end
  attr_reader :host, :port, :path, :headers
  equality :@host, :@port, :@path, :@headers
end
