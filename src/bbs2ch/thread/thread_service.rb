# -*- coding: utf-8 -*-
require 'bbs2ch/thread/cache_file'
require 'bbs2ch/thread/metadata'
require 'bbs2ch/thread/dat_builder'
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

    def dat_builder
      BBS2ch::DatBuilder.new
    end

    def cache_manager
      cache_source
    end

    def load_metadata
      metadata_manager.load
    end

    def metadata_manager
      TwoB::YAMLMarshaler.new(metadata_file, BBS2ch::Metadata.empty)
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

    def delta_request(metadata)
      HTTPRequest.new(host.name, 80, dat_path, metadata.dat_header)
    end

    def system
      host.system
    end

    def update(delta, metadata, time)
      return if delta.empty?
      cache_manager.append(delta.bytes)
      new_metadata = metadata.update(delta)
      new_metadata.last_modified = time
      metadata_manager.save(new_metadata)
      read_counter.update(@number, delta.last_res_number)
    end

    def read_counter
      board
    end
  end
end
