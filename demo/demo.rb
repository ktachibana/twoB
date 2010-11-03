#!/usr/bin/ruby -Ilib -Iview/lib -rubygems -rbin/webrick
# -*- coding: utf-8 -*-

class DemoContext < WEBrickFrontend
  def get_application(request)
    TwoB::Application.new(self, request, self)
  end

  def get_delta_input(request)
    demo_request = HTTPRequest.new("localhost", 8080, "/demo/" + request.host + request.path, request.headers)
    HTTPGetInput.new(demo_request)
  end

  def get_subject_source(request, encoder, line_delimiter)
    demo_request = HTTPRequest.new("localhost", 8080, "/demo/" + request.host + request.path, request.headers)
    HTTPGetSource.new(demo_request, encoder, line_delimiter)
  end

  def data_directory
    "demo/data"
  end
end

DemoContext.process
