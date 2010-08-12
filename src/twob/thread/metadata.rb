# -*- coding: utf-8 -*-

module TwoB
  class Metadata
    def initialize(last_res_number, cache_file_size, bookmark_number = nil)
      @last_res_number = last_res_number
      @cache_file_size = cache_file_size
      @bookmark_number = bookmark_number
      @index = {}
    end

    attr_accessor :last_res_number, :cache_file_size, :bookmark_number, :index

    def update(delta)
      append(delta.index)
      @last_res_number = delta.last_res_number
      @cache_file_size += delta.bytes_size
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
