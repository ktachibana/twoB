# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/thread/cache'

module JBBS
  class CacheManager
    include TwoB
    def initialize(cache_file)
      @cache_file = cache_file
    end

    attr_reader :cache_file

    def file_size
      @cache_file.size
    end

    def append(delta_bytes)
      @cache_file.append(delta_bytes)
    end

    def delete
      @cache_file.delete()
    end
  end
end
