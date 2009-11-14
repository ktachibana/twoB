# -*- coding: utf-8 -*-
require 'pathname'
require 'twob'
require 'spec_response'

class SpecSystem < TwoB::System
  SpecConfiguration = TwoB::Configuration.new(Pathname.new("local/spec_cache"))
  
  def initialize(request = nil)
    super(SpecConfiguration)
    @request = request
    @response = :yet_to_be_processed
    @buffer = StringIO.new
  end
  
  attr_accessor :request, :response
  
  def output(response)
    @response = SpecResponse.new(response)
    @response.write_body(@buffer)
  end
  
  def handle_error(e)
    super
    $stderr.puts(@buffer.string)
  end

  def self.clear_cache_dir
    SpecConfiguration.data_directory.rmtree
  end
end

