# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/thread'

module JBBS
  class ReadThreadAction
    def initialize(thread_key, picker)
      @thread_key = thread_key
      @picker = picker
      @metadata_manager = @thread_key.metadata_manager
      @cache_manager = @thread_key.cache_manager
    end

    def execute
      metadata = @metadata_manager.load()
      delta = @thread_key.load_delta(metadata)
      cache = @cache_manager.load(@picker.to_cache_ranges(metadata.last_res_number, delta.last_res_number, metadata.bookmark_number), metadata)
      
      thread_content = TwoB::Thread.new(@thread_key, cache, delta, @picker, metadata)
      
      @cache_manager.append(delta.bytes)
      
      metadata.update(delta)
      
      @metadata_manager.save(metadata)
      @thread_key.read_counter.update(@thread_key.number, thread_content.last_res_number) unless delta.empty?

      TwoB::ThreadView.new(thread_content)
    end
  end
end
