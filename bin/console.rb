#!/usr/bin/ruby -Isrc -Ilib -Iview/src -rubygems
# -*- coding: utf-8 -*-

require 'twob/application'
require 'twob/request'
require 'util/view'
require 'optparse'
require 'cgi'

class ConsoleFrontend
  include ViewUtil
  def data_directory
    "local/console_cache"
  end

  def output(response)
    $stdout.puts("<!-- Status: #{response.status_code} -->")
    $stdout.puts("<!-- #{h response.headers.inspect} -->")
    response.write_body($stdout)
  end

  def handle_error(e)
    raise e
  end

  def self.process
    path_info = ARGV.shift
    param = ARGV.empty? ? {} : CGI.parse(ARGV.shift)
    raise("missing path_info") unless path_info
    env = {"SCRIPT_NAME" => "/twoB/action", "REQUEST_URI" => "http://localhost/twoB/action" + path_info}
    request = TwoB::Request.new(path_info, param, env)

    TwoB::Application.new(self.new, request).main
  end
end

ConsoleFrontend.process
