# -*- coding: utf-8 -*-

require 'twob/thread'
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
      YAMLMarshaler.new(metadata_file, JBBS::Metadata.empty)
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
      new_metadata = metadata.update(delta)
      metadata_manager.save(new_metadata)
      read_counter.update(@number, delta.last_res_number)
    end

    def read_counter
      board
    end
  end

  class ThreadKey
    def initialize(board, number)
      @board = board
      @number = number
    end

    attr_reader :board, :number

    def system
      host.system
    end

    def category
      board.category
    end

    def host
      category.host
    end
  end

  class CacheManager
    include TwoB
    def initialize(cache_file)
      @cache_file = cache_file
    end

    attr_reader :cache_file

    def file_size
      @cache_file.size
    end

    def append(delta_bytes)
      @cache_file.append(delta_bytes)
    end

    def delete
      @cache_file.delete()
    end
  end

  class Metadata < TwoB::Metadata
    def initialize(last_res_number, cache_file_size, bookmark_number)
      super(last_res_number, cache_file_size, bookmark_number)
    end

    def self.empty
      self.new(0, 0, nil)
    end

    def delta_picker
      TwoB::Picker::From.new(@last_res_number + 1)
    end
  end
  
  TRIP_PATTERN = /\A([^<]*)(<\/b>\s*◆(\S+)\s*<b>)?\z/
  
  class DatBuilder
    include TwoB::Dat
    def initialize
      @number = 1
      @title = ""
      @res = []
    end

    def start(number)
      @number = number
    end

    def build(values, &filter)
      number = values[0].to_i
      name_string = values.fetch(1, "")
      name_match = TRIP_PATTERN.match(name_string)
      name = name_match ? name_match[1] : name_string
      trip = name_match ? name_match[3] : nil
      mail = values.fetch(2, "")
      date = values.fetch(3, "")
      body_text = values.fetch(4, "")
      id = values.fetch(6, "")
      res = TwoB::Dat::Line.new(number, name, trip, mail, date, id, parse_body(body_text))
      @title = values.fetch(5, "") if number == 1
      @res << res if filter.nil? || filter.call(res)
      @number += 1
      res
    end

    def result
      TwoB::Dat::Content.new(@title, @res)
    end
  end
end
