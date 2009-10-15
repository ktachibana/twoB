# -*- coding: utf-8 -*-
require 'pathname'
require 'twob/system'
require 'twob/configuration'

class SpecSystem < TwoB::System
  def initialize(request = nil)
    super(TwoB::Configuration.new(Pathname.new("spec_cache")))
    @request = request
    @buf = StringIO.new
  end
  
  attr_accessor :request, :response
  
  def response_body
    @buf.string
  end
  
  def get_request
    @request
  end
  
  def output(res)
    @response = res
    res.write_body(@buf)
  end
end
