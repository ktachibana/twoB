#!/usr/bin/ruby -Isrc -rubygems
$KCODE = "utf8"

require 'twob/system'
require 'twob/configuration'
require 'pathname'
require 'optparse'
require 'cgi'

path_info = ARGV.shift
param = ARGV.empty? ? {} : CGI.parse(ARGV.shift)

raise("missing path_info") unless path_info

configuration = TwoB::Configuration.new(Pathname.new("2bcache").expand_path)

class ConsoleSystem < TwoB::System
  def initialize(configuration)
    super(configuration)
  end
  
  def output(view)
    $stdout.puts("<!-- Status: #{view.status_code} -->")
    $stdout.puts("<!-- #{view.headers.inspect} -->")
    view.write($stdout)
  end
end

class ConsoleRequest
  def initialize(path_info, param)
    @path_info = path_info
    @param = param
  end

  attr_reader :path_info, :param
end

system = ConsoleSystem.new(configuration)
request = ConsoleRequest.new(path_info, param)
view = system.apply(request, path_info)
system.output(view)
