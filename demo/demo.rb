#!/usr/bin/ruby -Ilib -Iview/lib -rubygems -rtwoB-webrick
# -*- coding: utf-8 -*-
require 'io/http'
require 'twob'

class DemoFrontend < WEBrickFrontend
  def create_application(request)
    TwoB::Application.new(self, request, DemoBackend.new)
  end

class DemoBackend < TwoB::Backend
  def get_bytes(request)
    demo_request = HTTPRequest.new("localhost", 8080, "/demo/" + request.host + request.path, request.headers)
    HTTPGetInput.new(demo_request).read()
  end

  def get_subject_source(request, encoder, line_delimiter)
    demo_request = HTTPRequest.new("localhost", 8080, "/demo/" + request.host + request.path, request.headers)
    HTTPGetSource.new(demo_request, encoder, line_delimiter)
  end

  def data_directory
    "demo/data"
  end
end

DemoFrontend.process
