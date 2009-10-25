# -*- coding: utf-8 -*-
require 'pathname'
require 'twob/system'
require 'twob/configuration'
require 'twob/error_view'

class SpecSystem < TwoB::System
  def initialize(request = nil)
    super(TwoB::Configuration.new(Pathname.new("local/spec_cache")))
    @request = request
    @buffer = StringIO.new
  end
  
  attr_accessor :request, :response
  
  def handle_error(e)
    super
    $stderr.puts(response_body)
  end
  
  def response_body
    @buffer.string
  end
  
  def get_request
    @request
  end
  
  def output(response)
    @response = response
    response.write_body(@buffer)
  end
end
