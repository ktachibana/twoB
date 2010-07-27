#!/usr/bin/ruby -Isrc -Ilib -Iview/src -rubygems
# -*- coding: utf-8 -*-

require 'twob/system'
require 'twob/request'
require 'twob/configuration'
require 'util'
require 'pathname'
require 'optparse'
require 'cgi'

path_info = ARGV.shift
param = ARGV.empty? ? {} : CGI.parse(ARGV.shift)

raise("missing path_info") unless path_info

configuration = TwoB::Configuration.new(Pathname.new("local/console_cache").expand_path)

class ConsoleSystem < TwoB::System
  include ViewUtil
  def initialize(configuration, path_info, param)
    super(configuration)
    @path_info = path_info
    @param = param
    @request = TwoB::Request.new(@path_info, @param, {"SCRIPT_NAME" => "/twoB/action", "REQUEST_URI" => "http://localhost/twoB/action" + path_info})
  end

  attr_reader :request

  def output(response)
    $stdout.puts("<!-- Status: #{response.status_code} -->")
    $stdout.puts("<!-- #{h response.headers.inspect} -->")
    response.write_body($stdout)
  end

  def dump_error(response)
    response.write_body($stderr)
  end
end

system = ConsoleSystem.new(configuration, path_info, param)
system.process