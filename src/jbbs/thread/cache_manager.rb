require 'source'
require 'jbbs/thread/cache'
require 'jbbs/thread/dat_parser'

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
        return Cache.new(@dat_parser.parse_with_index(@cache_file, index, ranges))
      rescue Errno::ENOENT
        return Cache::Empty
      end
    end
    
    def append(delta)
      @cache_file.append(delta.bytes)
    end
    
    def delete
      @cache_file.delete()
    end
  end
end
