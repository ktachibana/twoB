# -*- coding: utf-8 -*-
require 'source'
require 'thread_view'
require 'twob/picker'
require 'twob/bbs_thread'
require 'jbbs/thread/cache'
require 'jbbs/thread/index'
require 'jbbs/thread/delta'

module JBBS
  class ReadThreadAction
    def initialize(thread, picker)
      @thread = thread
      @picker = picker
      @index_manager = @thread.index_manager
      @cache_manager = @thread.cache_manager
      @option_manager = @thread.option_manager
    end

    def execute
      index = @index_manager.load()
      delta = load_delta(index)
      cache_picker = @picker.concretize(delta.last_number).limitation(index.last_res_number).ranges
      cache = @cache_manager.load(cache_picker, index)
      option = @option_manager.load()
      
      thread_content = TwoB::Thread.new(@thread, cache, delta, @picker, option)
      
      @cache_manager.append(delta)

      index.last_res_number = thread_content.last_res_number
      index.append(delta.index)
      index.cache_file_size = @cache_manager.file_size

      @index_manager.save(index)
      @thread.read_counter.update(@thread.number, thread_content.last_res_number)

      ::ThreadView.new(thread_content)
    end
    
    def load_delta(index)
      new_bytes = @thread.load_new(index.delta_picker)
      Delta.new(@thread, index, new_bytes)
    end
  end
end
