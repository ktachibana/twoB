# -*- coding: utf-8 -*-
require 'twob'
require 'jbbs/thread/thread_key'
require 'jbbs/thread/cache_manager'
require 'jbbs/thread/read_thread_action'
require 'io'
require 'yaml_marshaler'

module JBBS
  class ThreadService
    extend Forwardable
    
    def initialize(board, number)
      @board = board
      @number = number
      @key = ThreadKey.new(board, number)
    end
    
    def_delegators :@key, :board, :number
    
    def category
      board.category
    end
    
    def host
      category.host
    end
    
    
    
    include TwoB::ThreadHandler
    
    def get_child(value)
      Res.new(self, value.to_i)
    end
    
    def read(picker)
      ReadThreadAction.new(self, picker).execute()
    end
    
    def index_manager
      TwoB::YAMLMarshaler.new(index_file, TwoB::Index.Empty)
    end
    
    def cache_manager
      JBBS::CacheManager.new(cache_source, get_dat_parser())
    end

    def cache_source
      TextFile.new(cache_file, dat_encoding)
    end
    
    def data_directory_path
      board.data_directory_path
    end
    
    def original_url
      "http://#{host.name}/bbs/read.cgi/#{category.name}/#{board.number}/#{number}/"
    end
    
    def get_dat_url(picker)
      "http://#{host.name}#{get_dat_path(picker)}"
    end
  
    def dat_encoding
      "EUC-JP-MS"
    end
    
    def get_dat_path(picker)
      "/bbs/rawmode.cgi/#{category.name}/#{board.number}/#{number}/#{picker}"
    end
    
    def load_new(picker)
      get_new_input(picker).read()
    end

    def get_new_input(picker)
      HTTPGetInput.new(HTTPRequest.new(host.name, get_dat_path(picker), {}))
    end
    
    def get_dat_parser()
      DatParser.new
    end
    
    def system
      host.system
    end
    
    def read_counter
      board
    end

    def res_anchor(picker)
      index = index_manager.load
      ranges = picker.concretize(index.last_res_number).ranges
      cache = cache_manager.load(ranges, index)
      anchor_res = []
      cache.each_res do |res|
        anchor_res << TwoB::Res.as_cache(res)
      end
      TwoB::ResAnchorView.new(anchor_res)
    end
  end
end
