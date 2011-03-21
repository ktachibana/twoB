# -*- coding: utf-8 -*-
require 'twob/thread'
require 'io'
require 'delegate'
require 'time'

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
      YAMLMarshaler.new(metadata_file, BBS2ch::Metadata.empty)
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
  
  class CacheFile < SimpleDelegator
    include TwoB
    def initialize(cache_file)
      @cache_file = cache_file
      super(cache_file)
    end

    attr_reader :cache_file, :dat_parser

  end

  class Metadata < TwoB::Metadata
    def initialize(last_res_number, cache_file_size, bookmark_number, last_modified)
      super(last_res_number, cache_file_size, bookmark_number)
      @last_modified = last_modified
    end

    def self.empty
      new(0, 0, nil, nil)
    end

    attr_accessor :last_modified
    
    def empty?
      @last_modified.nil?
    end

    def dat_header
      header = {}
      return header if empty?
      header["Range"] = "bytes=#{@cache_file_size}-" unless @cache_file_size.zero?
      header["If-Modified-Since"] = last_modified.httpdate if last_modified
      header
    end
  end

  class DatLine < TwoB::Dat::Line
    def initialize(number, name, trip, mail, date, id, be, body)
      super(number, name, trip, mail, date, id, body)
      @be = be
    end

    attr_reader :be
  end

  DATE_PATTERN = /\A(.*?)( ID:(\S+))?( BE:(.*))?\z/
  TRIP_PATTERN = /\A([^<]*)( <\/b>\s*◆(\S+)\s*<b>)?\z/
  
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
      name_string = values.fetch(0, "")
      name_match = TRIP_PATTERN.match(name_string)
      name = name_match ? name_match[1] : name_string
      trip = name_match ? name_match[3] : nil
      mail = values.fetch(1, "")
      date_id_be_string = values.fetch(2, "")
      date_match = DATE_PATTERN.match(date_id_be_string)
      date = date_match ? date_match[1] : ""
      id = date_match ? date_match[3] : nil
      be = date_match ? date_match[5] : nil
      body_text = values.fetch(3, "").lstrip
      res = BBS2ch::DatLine.new(@number, name, trip, mail, date, id, be, parse_body(body_text))
      @title = values.fetch(4, "") if @number == 1
      @res << res if filter.nil? || filter.call(res)
      @number += 1
      res
    end

    def result
      TwoB::Dat::Content.new(@title, @res)
    end
  end

end
