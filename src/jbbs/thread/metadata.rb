# -*- coding: utf-8 -*-
require 'twob/thread/metadata'
require 'twob/thread/picker'

module JBBS
  class Metadata < TwoB::Metadata
    def initialize(last_res_number, cache_file_size, bookmark_number = nil)
      super(last_res_number, cache_file_size)
    end

    def self.empty
      self.new(0, 0)
    end

    def delta_picker
      TwoB::Picker::From.new(@last_res_number + 1)
    end
  end
end
