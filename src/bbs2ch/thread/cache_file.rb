# -*- coding: utf-8 -*-
require 'twob/thread/cache'
require 'io/file'
require 'delegate'

module BBS2ch
  class CacheFile < SimpleDelegator
    include TwoB
    
    def initialize(cache_file)
      @cache_file = cache_file
      super(cache_file)
    end
    
    attr_reader :cache_file, :dat_parser
    
  end
end
