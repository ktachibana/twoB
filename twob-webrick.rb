#!/usr/bin/ruby -Isrc
# -*- coding: utf-8 -*-

require 'twob/system'
require 'twob/configuration'
require 'twob/request'
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
  
  def get_request
    TwoB::Request.new(@request.path_info, CGI.parse(@request.query_string ? @request.query_string : ""))
  end

  def output(response)
    @response.status = response.status_code
    response.headers.each do |key, value|
      @response[key] = value
    end
    io = StringIO.new
    response.write_body(io)
    @response.body = io.string
  end
end

$configuration = TwoB::Configuration.new(Pathname.new("2bcache").expand_path)

server = WEBrick::HTTPServer.new({:DocumentRoot => './', :Port => 8080})
server.mount_proc("/twoB/test") do |request, response|
  system = WEBrickSystem.new($configuration, request, response)
  system.process
end
[:INT, :TERM].each do |signal|
  trap(signal){ server.stop }
end

server.start
