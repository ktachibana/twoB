#!/usr/bin/ruby -Isrc -Ilib -Iview/src -rubygems
# -*- coding: utf-8 -*-

$KCODE = "utf8"

require 'twob/application'
require 'twob/request'
require 'twob/error_view'
require 'fcgi'
require 'cgi'

module TwoB
  class FastCGIFrontend
    def initialize(fcgi)
      @fcgi = fcgi
    end

    def self.process
      FCGI.each do |fcgi|
        path_info = fcgi.env["PATH_INFO"]
        query = fcgi.env["QUERY_STRING"]
        param = CGI.parse(query || "")
        request = TwoB::Request.new(path_info, param, fcgi.env)
        TwoB::Application.new(self.new(fcgi), request).process

        fcgi.finish
      end
    end

    def data_directory
      "2bcache"
    end

    def output(response)
      @fcgi.out.print("Status: #{response.status_code}\r\n")
      response.headers.each do |key, value|
        @fcgi.out.print("#{key}: #{value}\r\n")
      end
      @fcgi.out.print("\r\n")
      response.write_body(@fcgi.out)
    end

    def handle_error(e)
      output(ErrorView.new(e))
    end
  end
end

TwoB::FastCGIFrontend.process
