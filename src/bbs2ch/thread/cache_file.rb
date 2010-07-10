# -*- coding: utf-8 -*-
require 'twob/thread/cache'
require 'io/file'
require 'delegate'

module BBS2ch
  class CacheFile < SimpleDelegator
    include TwoB
    
    def initialize(cache_file, dat_parser)
      @cache_file = cache_file
      @dat_parser = dat_parser
      super(cache_file)
    end
    
    attr_reader :cache_file, :dat_parser
    
    def load(ranges, metadata)
      begin
        Cache.new(dat_parser.parse_cache(cache_file, metadata.index, ranges))
      rescue Errno::ENOENT
        return Cache::Empty
      end      
    end
  end
end
