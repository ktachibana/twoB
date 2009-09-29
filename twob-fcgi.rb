#!/usr/bin/ruby -Isrc -rubygems
# -*- coding: utf-8 -*-
$KCODE = "utf8"

require 'twob/system'
require 'twob/configuration'
require 'fcgi'
require 'cgi'
require 'pathname'
require 'error_view'

module TwoB
  class FCGISystem < System
    def initialize(configuration, fcgi)
      super(configuration)
      @fcgi = fcgi
    end
    
    def output(view)
      @fcgi.out.print("Status: #{view.status_code}\r\n")
      view.headers.each{|key, value|
        @fcgi.out.print("#{key}: #{value}\r\n")
      }
      @fcgi.out.print("\r\n")
      view.write(@fcgi.out)
    end
  end
  
  class FCGIRequest
    def initialize(fcgi)
      @param = CGI.parse(fcgi.env["QUERY_STRING"])
      @path_info = fcgi.env["PATH_INFO"]
    end

    attr_reader :param, :path_info
  end
end

configuration = TwoB::Configuration.new(Pathname.new("2bcache").expand_path)

FCGI.each do |fcgi|
  begin
    system = TwoB::FCGISystem.new(configuration, fcgi)
    request = TwoB::FCGIRequest.new(fcgi)
    view = system.apply(request, request.path_info)
  rescue Exception => e
    system.output(ErrorView.new(e))
  else
    system.output(view)
  end
  fcgi.finish()
end

