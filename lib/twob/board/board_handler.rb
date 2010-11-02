# -*- coding: utf-8 -*-
require 'twob/handler'
require 'twob/board/subject'
require 'twob/board/board_view'
require 'yaml_marshaler'

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
      TwoB::YAMLMarshaler.new(metadata_file, Hash.new)
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
  end
end
