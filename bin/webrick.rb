#!/usr/bin/ruby -Isrc -Ilib -Iview/src -rubygems
# -*- coding: utf-8 -*-

require 'twob/application'
require 'twob/request'
require 'twob/error_view'
require 'webrick'
require 'cgi'
require 'stringio'

class WEBrickFrontend
  def initialize(webrick_response)
    @webrick_response = webrick_response
  end

  def self.process
    server = WEBrick::HTTPServer.new({:DocumentRoot => './', :Port => 8080})
    server.mount_proc("/twoB/action") do |webrick_request, webrick_response|
      param = CGI.parse(webrick_request.query_string || "")
      request = TwoB::Request.new(webrick_request.path_info, param, webrick_request.meta_vars)
      TwoB::Application.new(self.new(webrick_response), request).main
    end

    [:INT, :TERM].each do |signal|
      trap(signal){ server.stop }
    end
    server.start
  end

  def data_directory
    "data"
  end

  def output(response)
    @webrick_response.status = response.status_code
    response.headers.each do |key, value|
      @webrick_response[key] = value
    end
    io = StringIO.new
    response.write_body(io)
    @webrick_response.body = io.string
  end

  def handle_error(e)
    output(ErrorView.new(e))
  end
end

WEBrickFrontend.process
