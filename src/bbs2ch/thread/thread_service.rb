# -*- coding: utf-8 -*-
require 'bbs2ch/thread/read_thread_action'
require 'bbs2ch/thread/cache_file'
require 'bbs2ch/thread/res'
require 'bbs2ch/thread/index'
require 'time'
require 'yaml_marshaler'
require 'io'
require 'twob'

module BBS2ch
  class ThreadService
    def initialize(board, number)
      @board = board
      @number = number
    end
    
    attr_reader :board, :number
    
    def host
      @board.host
    end
    
    
    include TwoB::ThreadHandler
    
    def get_child(value)
      BBS2ch::Res.new(self, value.to_i)
    end
    
    def read(requested_picker)
      BBS2ch::ReadThreadAction.new(self, requested_picker).execute()
    end
    
    def cache_manager
      BBS2ch::CacheFile.new(cache_source, get_dat_parser())
    end
    
    def index_manager
      TwoB::YAMLMarshaler.new(index_file, BBS2ch::Index.empty)
    end
    
    def original_url
      "http://#{board.host.name}/test/read.cgi/#{board.id}/#{number}/"
    end
    
    def data_directory_path
      board.data_directory_path
    end
    
    def get_dat_url(picker)
      dat_url
    end
    
    def dat_url
      "http://#{dat_host_name}#{dat_path}"
    end
    
    def dat_host_name
      board.host.name
    end
    
    def dat_path
      "/#{board.id}/dat/#{number}.dat"
    end
    
    def get_dat_url(from)
      dat_url
    end
    
    def cache_source
      TextFile.new(cache_file, dat_encoding.name)
    end
    
    def dat_encoding
      Encoder.by_name("Windows-31J")
    end
    
    def get_new_input(request)
      HTTPGetInput.new(request)
    end
    
    def get_dat_parser()
      BBS2ch::DatParser.new()
    end
    
    def system
      board.host.system
    end
    
    def read_counter
      board
    end
  end
end
