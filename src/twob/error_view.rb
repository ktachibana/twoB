# -*- coding: utf-8 -*-
require 'view_util'

class ErrorView
  include ViewUtil

  def initialize(error)
    @error = error
  end

  attr_reader :error

  def status_code
    500
  end
  
  def content_type
    "text/plain; charset=UTF-8"
  end
  
  def headers
    {"Content-Type" => content_type}
  end

  def write_body(out)
    out.puts(error.inspect)
    error.backtrace.each do|trace|
      out.puts(trace)
    end
  end
end
