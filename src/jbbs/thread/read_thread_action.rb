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
      @option_manager = @thread_key.option_manager
    end

    def execute
      index = @index_manager.load()
      delta = load_delta(index)
      cache = @cache_manager.load(cache_picker(delta, index), index)
      option = @option_manager.load()
      
      thread_content = TwoB::Thread.new(@thread_key, cache, delta, @picker, option)
      
      @cache_manager.append(delta.bytes)
      
      index.update(delta)
      
      @index_manager.save(index)
      @thread_key.read_counter.update(@thread_key.number, thread_content.last_res_number)

      TwoB::ThreadView.new(thread_content)
    end
    
    def cache_picker(delta, index)
      @picker.concretize(last_res_number(delta, index)).limitation(index.last_res_number).ranges
    end
    
    def last_res_number(delta, index)
      delta.last_number ? delta.last_number : index.last_res_number
    end
    
    def load_delta(index)
      dat_parser = @thread_key.get_dat_parser
      bytes = @thread_key.load_new(index.delta_picker)
      source = BytesSource.new(bytes, Encoder.by_name(@thread_key.dat_encoding), "\n")

      dat_content = dat_parser.parse_delta(source)
      TwoB::Delta.new(dat_content, bytes, dat_parser.index)
    end
  end
end
