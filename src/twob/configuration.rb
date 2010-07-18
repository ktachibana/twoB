# -*- coding: utf-8 -*-

module TwoB
  class Configuration
    def initialize(data_directory)
      @data_directory = data_directory
    end

    attr_reader :data_directory
  end
end
