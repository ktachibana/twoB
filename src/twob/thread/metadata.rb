# -*- coding: utf-8 -*-

module TwoB
  class Metadata
    def initialize
      @cache_byte_size = 0
      @last_res_number = 0
      @index = {}
      @title = ""
    end
    
    def delta_picker
      Picker::From.new(@last_res_number + 1)
    end
    
    def append(delta_index)
      delta_index.each do |number, source_offset|
        @index[number] = @cache_file_size + source_offset
      end
    end
    
  end
end