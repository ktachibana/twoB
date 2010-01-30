# -*- coding: utf-8 -*-
require 'bbs2ch/thread/cache'

module BBS2ch
  class CacheManager
    def initialize(cache_file, dat_parser, empty)
      @cache_file = cache_file
      @dat_parser = dat_parser
      @empty = empty
    end
    
    attr_reader :cache_file, :dat_parser, :empty
    
    def load(index, ranges)
      begin
        Cache.new(dat_parser.parse_with_index(cache_file, index, ranges), cache_file)
      rescue Errno::ENOENT
        return empty
      end      
    end
    
    def append(new_data)
      cache_file.append(new_data)
    end

    def delete()
      cache_file.delete()
    end
  end
end
