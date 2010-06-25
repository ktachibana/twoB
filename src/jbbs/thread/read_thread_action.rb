# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/thread'

module JBBS
  class ReadThreadAction
    def initialize(thread_key, picker)
      @thread_key = thread_key
      @picker = picker
      @index_manager = @thread_key.index_manager
      @cache_manager = @thread_key.cache_manager
    end

    def execute
      index = @index_manager.load()
      delta = @thread_key.load_delta(index)
      cache = @cache_manager.load(@picker.to_cache_ranges(index.last_res_number, delta.last_res_number, index.bookmark_number), index)
      
      thread_content = TwoB::Thread.new(@thread_key, cache, delta, @picker, index)
      
      @cache_manager.append(delta.bytes)
      
      index.update(delta)
      
      @index_manager.save(index)
      @thread_key.read_counter.update(@thread_key.number, thread_content.last_res_number) unless delta.empty?

      TwoB::ThreadView.new(thread_content)
    end
  end
end
