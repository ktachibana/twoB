#!/usr/bin/ruby -Ilib -Iview/lib -rubygems
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
        param = CGI.parse(fcgi.env["QUERY_STRING"] || "")
        env = fcgi.env
        request = TwoB::Request.new(path_info, param, env)

        TwoB::Application.new(self.new(fcgi), request).main

        fcgi.finish
      end
    end

    def data_directory
      "local/data"
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
