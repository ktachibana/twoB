#!/usr/bin/ruby -Ilib -Iview/lib -rubygems
# -*- coding: utf-8 -*-

require 'twob/application'
require 'framework/request'
require 'framework/error_view'
require 'webrick'
require 'cgi'
require 'stringio'

class WEBrickFrontend
  def initialize(webrick_response)
    @webrick_response = webrick_response
  end

  def self.process
    server = WEBrick::HTTPServer.new({:DocumentRoot => './web', :Port => 8080})
    server.mount_proc("/twoB/action") do |webrick_request, webrick_response|
      param = CGI.parse(webrick_request.query_string || "")
      request = TwoB::Request.new(webrick_request.path_info, param, webrick_request.meta_vars)

      self.new(webrick_response).create_application(request).main
    end

    [:INT, :TERM].each do |signal|
      trap(signal){ server.stop }
    end
    server.start
  end

  def create_application(request)
    TwoB::Application.new(self, request)
  end

  def data_directory
    "local/data"
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

if $0 == __FILE__
  WEBrickFrontend.process
end
