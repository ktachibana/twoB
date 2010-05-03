# -*- coding: utf-8 -*-
require 'bbs2ch/thread/read_thread_action'
require 'bbs2ch/thread/cache_file'
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
      TwoB::ResService.new(self, value.to_i)
    end
    
    def read(requested_picker)
      BBS2ch::ReadThreadAction.new(self, requested_picker).execute()
    end
    
    def cache_manager
      BBS2ch::CacheFile.new(cache_source, BBS2ch::DatParser.new)
    end
    
    def index_manager
      TwoB::YAMLMarshaler.new(index_file, BBS2ch::Index.empty)
    end
    
    def original_url
      "http://#{host.name}/test/read.cgi/#{board.id}/#{number}/"
    end
    
    def dat_url
      "http://#{host.name}#{dat_path}"
    end
    
    def dat_path
      "/#{board.id}/dat/#{number}.dat"
    end
    private :dat_path
    
    def dat_encoding_name
      "Windows-31J"
    end
    
    def dat_line_delimiter
      "\n"
    end
    
    def delta_request(index)
      HTTPRequest.new(host.name, dat_path, index.dat_header)
    end
    
    def get_delta_parser(initial_number)
      BBS2ch::DatParser.new(initial_number)
    end
    
    def system
      host.system
    end
    
    def read_counter
      board
    end
  end
end
