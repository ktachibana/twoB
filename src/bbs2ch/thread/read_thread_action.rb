# -*- coding: utf-8 -*-
require 'bbs2ch/thread/dat_parser'
require 'twob/thread'
require 'io/source'
require 'encoder'

module BBS2ch
  class ReadThreadAction
    def initialize(thread_key, picker)
      @thread_key = thread_key
      @picker = picker
      @cache_manager = @thread_key.cache_manager
    end
    
    def execute
      builder = ThreadBuilder.new(@thread_key, @thread_key, @picker)
      @picker.build_thread(builder)
      
      TwoB::ThreadView.new(builder.result)
    end
  end
end
