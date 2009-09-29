#!/usr/bin/ruby -Isrc
# -*- coding: utf-8 -*-

require 'twob/system'
require 'twob/configuration'
require 'stringio'
require 'webrick'
require 'cgi'
require 'pathname'

class WEBrickSystem < TwoB::System
  def initialize(configuration, request, response)
    super(configuration)
    @request = request
    @response = response
  end

  def output(view)
    @response.status = view.status_code
    view.headers.each{|key, value|
      @response[key] = value
    }
    io = StringIO.new
    view.write(io)
    @response.body = io.string
  end
end

class WEBrickRequest
  def initialize(request)
    @request = request
  end
  
  def param
    CGI.parse(@request.query_string)
  end
  
  def path_info
    @request.path_info
  end
end

$configuration = TwoB::Configuration.new(Pathname.new("2bcache").expand_path)

server = WEBrick::HTTPServer.new({:DocumentRoot => '../', :Port => 8080})
server.mount_proc("/twoB/test") do |request, response|
  system = WEBrickSystem.new($configuration, request, response)
  view = system.apply(WEBrickRequest.new(request), request.path_info)
  system.output(view)
end
[:INT, :TERM].each do |signal|
  trap(signal){ server.stop }
end

server.start
