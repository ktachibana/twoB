#!/usr/bin/ruby
require 'erb'

source_file = ARGV.shift

erb_source = ""
class_name = ""
params = []
content_type = ""

File.foreach(source_file) do |line|
  if line.strip.match(/\<\%\#\@\s*(\w+)\s*:(.*)\%\>/)
    case $1
    when "class_name"
      class_name = $2.strip
    when "param"
      params << $2.strip
    when "content_type"
      content_type = $2.strip
    end
  else
    erb_source << line
  end
end

src = ERB.new(erb_source, nil, "%>").src
src.sub!(/_erbout = ''; /, "")

script = <<EOS
require 'view_util'

class <%= class_name %>
  include ViewUtil

  def initialize(<%= params.join(", ") %>)
% params.each do |param|
    @<%= param %> = <%= param %>
% end
  end

% params.each do |param|
  attr_reader :<%= param %>
% end

  def status_code
    200
  end
  
  def content_type
    "<%= content_type %>"
  end
  
  def headers
    {"Content-Type" => content_type}
  end

  def write(_erbout)
    def _erbout.concat(str)
      self << str
    end

% src.each_line do |line|
    <%= line.strip %>
% end
  end
end
EOS

puts ERB.new(script, nil, "%").result

