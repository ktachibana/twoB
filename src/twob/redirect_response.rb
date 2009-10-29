# -*- coding: utf-8 -*-

class RedirectResponse
  def initialize(location)
    @location = location
  end
  
  def status_code
    303
  end
  
  def headers
    {"Location" => @location}
  end
  
  def write(output)
  end
end