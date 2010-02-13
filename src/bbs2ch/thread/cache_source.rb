# -*- coding: utf-8 -*-
require 'bbs2ch/thread/cache'
require 'io/file'

module BBS2ch
  class CacheSource < TextFile
    def initialize(cache_file, dat_parser)
      @cache_file = cache_file
      @dat_parser = dat_parser
    end
    
    attr_reader :cache_file, :dat_parser
    
    def load(ranges, index)
      begin
        Cache.new(dat_parser.parse_with_index(cache_file, index, ranges))
      rescue Errno::ENOENT
        return Cache::Empty
      end      
    end
    
    def append(delta_bytes)
      cache_file.append(delta_bytes)
    end

    def delete()
      cache_file.delete()
    end
  end
end
