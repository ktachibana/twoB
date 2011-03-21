# -*- coding: utf-8 -*-

require 'framework/handler'
require 'twob/board_view'
require 'yaml_marshaler'
require 'util'

module TwoB
  module BoardHandler
    include Handler

    BoardInfo = Struct.new(:url)
    def execute(request, value)
      list_thread()
    end

    def get_subjects()
      request = HTTPRequest.new(host.name, 80, subject_path, {})
      source = system.get_subject_source(request, Encoder.by_name(subject_encoding), subject_line_delimiter)
      get_subject_parser.parse(source)
    end

    def metadata_file
      data_directory + data_directory_path + "board.yaml"
    end

    def metadata_manager
      YAMLMarshaler.new(metadata_file, Hash.new)
    end

    def data_directory
      system.configuration.data_directory
    end

    def list_thread()
      board = BoardInfo.new(original_url)
      subjects = get_subjects()
      index_map = metadata_manager.load()
      threads = subjects.collect do |subject|
        TwoB::ThreadSubject.new(subject, index_map.fetch(subject.number, 0))
      end
      threads.sort! do |a, b|
        result = 0
        result = high_true(a, b){|v| v.read? } if result.zero?
        result = high_true(a, b){|v| v.has_new? } if result.zero?
        result = high_true(a, b){|v| v.has_new? && v.res_count == 1000 } if result.zero?
        result = high_true(a, b){|v| !v.has_new? && v.res_count != 1000 } if result.zero?
        result = -(a.new_count <=> b.new_count) if result.zero?
        result = a.order <=> b.order if result.zero?
        result
      end
      BoardView.new(board, threads)
    end

    def high_true(a, b)
      -((yield(a) ? 1 : 0) <=> (yield(b) ? 1 : 0))
    end

    def update(thread_number, read_count)
      metadata_manager.update do |board_metadata|
        board_metadata[thread_number] = read_count
      end
    end

    def delete(thread_number)
      metadata_manager.update do |board_metadata|
        board_metadata.delete(thread_number)
      end
    end
  end

  class SubjectParser
    def initialize(line_pattern)
      @line_pattern = line_pattern
    end

    def parse(source)
      result = []
      source.each_with_index do |line, index|
        next if line.empty?
        match = @line_pattern.match(line)
        unless match
          result << ThreadSubject::Item.new(index + 1, "", "?")
          next
        end
        number = match[1]
        title = match[2]
        res_count = match[3].to_i
        result << ThreadSubject::Item.new(index + 1, number, title, res_count)
      end
      result
    end
  end

  class ThreadSubject
    Item = Struct.new(:order, :number, :title, :res_count)
    def initialize(content, read_count)
      @content = content
      @read_count = read_count
    end

    equality :@content, :@read_count

    def order
      @content.order
    end

    def number
      @content.number
    end

    def title
      @content.title
    end

    def read?
      @read_count.nonzero?
    end

    def res_count
      @content.res_count
    end

    def read_count
      @read_count
    end

    def new_count
      read_count != 0 ? res_count - read_count : 0
    end

    def has_new?
      new_count.nonzero?
    end
  end
end
