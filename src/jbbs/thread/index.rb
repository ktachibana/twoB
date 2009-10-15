require 'marshaler'
require 'twob/thread/dat'
require 'twob/thread/picker'

module JBBS
  class Index
    def initialize(last_res_number, cache_file_size)
      @last_res_number = last_res_number
      @cache_file_size = cache_file_size
      @index = {}
    end
    
    def self.Empty
      self.new(0, 0)
    end
    
    attr_accessor :last_res_number, :cache_file_size
    
    def delta_picker
      TwoB::Picker::From.new(@last_res_number + 1)
    end
    
    def append(delta_index)
      delta_index.each do |number, source_offset|
        @index[number] = @cache_file_size + source_offset
      end
    end
    
    def has?(number)
      @index.has_key?(number)
    end
    
    def [](res_number)
      @index[res_number]
    end
    
    def []=(res_number, offset)
      @index[res_number] = offset
    end
  end
end
