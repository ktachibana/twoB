# -*- coding: utf-8 -*-
require 'io/source'
require 'twob/thread/thread_view'
require 'twob/thread/picker'
require 'twob/thread/bbs_thread'
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

    def build_thread
      metadata = @metadata_manager.load
      @builder.set_title(metadata.title)
      
    end
    
    def execute
      index = @index_manager.load()
      delta = load_delta(index)
      cache_picker = @picker.concretize(delta.last_number ? index.last_res_number : delta.last_number).limitation(index.last_res_number).ranges
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
      dat_parser = @thread.get_dat_parser
      bytes = @thread.load_new(index.delta_picker)
      source = BytesSource.new(bytes, Encoder.by_name(@thread.dat_encoding), "\n")

      dat_content = dat_parser.parse(source)
      Delta.new(dat_content, dat_parser.index)
    end
  end
end
