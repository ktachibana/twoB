# -*- coding: utf-8 -*-
require 'equality'

module TwoB
  class Request
    def initialize(path_info, param = {})
      @path_info = path_info
      @param = param
    end
    attr_reader :path_info, :param
    equality :@path_info, :@param
  end
end
