# -*- coding: utf-8 -*-
require 'io/source'
require 'jbbs/thread'

module JBBS
  class CacheManager
    def initialize(cache_file, dat_parser)
      @cache_file = cache_file
      @dat_parser = dat_parser
    end
    
    attr_reader :cache_file, :dat_parser
    
    def file_size
      @cache_file.size
    end
    
    def load(ranges, index)
      begin
        return TwoB::Cache.new(@dat_parser.parse_with_index(@cache_file, index, ranges))
      rescue Errno::ENOENT
        return Cache::Empty
      end
    end
    
    def append(delta_bytes)
      @cache_file.append(delta_bytes)
    end
    
    def delete
      @cache_file.delete()
    end
  end
end
