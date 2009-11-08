#!/usr/bin/ruby -Isrc -Ilib -rubygems
# -*- coding: utf-8 -*-

$KCODE = "utf8"

require 'twob/system'
require 'twob/configuration'
require 'twob/request'
require 'fcgi'
require 'cgi'
require 'pathname'
require 'twob/error_view'

module TwoB
  class FCGISystem < System
    def initialize(configuration, fcgi)
      super(configuration)
      @fcgi = fcgi
      path_info = @fcgi.env["PATH_INFO"]
      query = @fcgi.env["QUERY_STRING"]
      @request = TwoB::Request.new(path_info, CGI.parse(query ? query : ""))
    end
    
    attr_reader :request
    
    def output(response)
      @fcgi.out.print("Status: #{response.status_code}\r\n")
      response.headers.each do |key, value|
        @fcgi.out.print("#{key}: #{value}\r\n")
      end
      @fcgi.out.print("\r\n")
      response.write_body(@fcgi.out)
    end
  end
end


configuration = TwoB::Configuration.new(Pathname.new("2bcache").expand_path)

FCGI.each do |fcgi|
  system = TwoB::FCGISystem.new(configuration, fcgi)
  system.process
  fcgi.finish
end

