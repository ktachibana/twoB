#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'erb'

module ERB2View
  module_function
  
  def convert_io(input, output)
    erb_source = ""
    class_name = ""
    params = []
    content_type = ""

    input.each_line do |line|
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

    script = File.read("tools/view_template.erb")

    output.puts(ERB.new(script, nil, "%").result(binding))
  end

  def convert(input_file, output_file)
    File.open(input_file) do |input|
      File.open(output_file, "w") do |output|
        convert_io(input, output)
      end
    end
  end
end

if __FILE__ == $0
  ERB2View.convert_io($<, $>)
end
