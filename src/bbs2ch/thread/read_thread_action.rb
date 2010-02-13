# -*- coding: utf-8 -*-
require 'bbs2ch/thread/dat_parser'
require 'twob/thread'
require 'io/source'

module BBS2ch
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
      index.last_modified = Time.now
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
      delta_bytes = load_delta_bytes(index)
      dat_parser = BBS2ch::DatParser.new(index.last_res_number + 1)
      delta_content = dat_parser.parse_delta(InputSource.new(StringInput.new(delta_bytes), @thread_key.dat_encoding, "\n"))
      TwoB::Delta.new(delta_content, delta_bytes, dat_parser.index)
    end
    
    def load_delta_bytes(index)
      request = HTTPRequest.new(@thread_key.host.name, @thread_key.dat_path, index.dat_header)
      @thread_key.get_new_input(request).read()
    end
    
  end
end
