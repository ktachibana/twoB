# -*- coding: utf-8 -*-
require 'equality'

module TwoB
  class HTTPRequest
    def initialize(host, path, headers)
      @host = host
      @path = path
      @headers = headers
    end
    attr_reader :host, :path, :headers
    equality :@host, :@path, :@headers
  end
end
