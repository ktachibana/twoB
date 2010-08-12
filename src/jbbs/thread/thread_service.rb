# -*- coding: utf-8 -*-
require 'twob'
require 'twob/thread/thread_handler'
require 'twob/thread/res_service'
require 'jbbs/thread/metadata'
require 'jbbs/thread/thread_key'
require 'jbbs/thread/cache_manager'
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

    def dat_builder
      JBBS::DatBuilder.new
    end

    def cache_manager
      JBBS::CacheManager.new(cache_source)
    end

    def load_metadata
      metadata_manager.load
    end

    def metadata_manager
      TwoB::YAMLMarshaler.new(metadata_file, JBBS::Metadata.empty)
    end

    def original_url
      "http://#{host.name}/bbs/read.cgi/#{category.name}/#{board.number}/#{number}/"
    end

    def dat_url
      "http://#{host.name}#{get_dat_path(TwoB::Picker::All.instance)}"
    end

    def get_dat_path(picker)
      "/bbs/rawmode.cgi/#{category.name}/#{board.number}/#{number}/#{picker}"
    end
    private :get_dat_path

    def dat_encoding_name
      "EUC-JP-MS"
    end

    def dat_line_delimiter
      "\n"
    end

    def delta_request(metadata)
      HTTPRequest.new(host.name, 80, get_dat_path(metadata.delta_picker), {})
    end

    def system
      host.system
    end

    def update(delta, metadata, time)
      return if delta.empty?
      cache_manager.append(delta.bytes)
      metadata.update(delta)
      metadata_manager.save(metadata)
      read_counter.update(@number, delta.last_res_number)
    end

    def read_counter
      board
    end
  end
end
