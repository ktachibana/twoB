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

  def write(out)
    out << error.inspect
    out << "\r\n"
    error.backtrace.each{|trace|
      out << trace
      out << "\r\n"
    }
  end
end
