#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'erb'

module ERB2View
  module_function
  
  def convert_io(input, output)
    erb_source = ""
    class_name = ""
    module_name = ""
    params = []
    content_type = ""

    input.each_line do |line|
      if match = line.strip.match(/\<\%\#\@\s*(\w+)\s*:\s*(.*?)\s*\%\>/)
        key = match[1]
        value = match[2]
        case key
        when "class_name"
          class_name = value
        when "module_name"
          module_name = value
        when "param"
          params << value
        when "content_type"
          content_type = value
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
