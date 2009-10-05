# -*- coding: utf-8 -*-
require 'pathname'
require 'twob/system'
require 'twob/configuration'

class SpecSystem < TwoB::System
  def initialize()
    @configuration = TwoB::Configuration.new(Pathname.new("spec_cache"))
  end
  
  attr_reader :configuration
end

class SpecRequest
  def initialize(param, path_info)
    @param = param
    @path_info = path_info
  end

  attr_reader :param, :path_info
end
