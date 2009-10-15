# -*- coding: utf-8 -*-
require "twob/board/subject"
require "twob/board/board_view"
require 'marshaler'

module TwoB
  # = includeするクラスは以下のメソッドを提供すること
  # * [original_url] String 板をブラウザで通常表示するためのURL
  # * [subject_url] String subject.txtのURL
  # * [get_subject_parser] TwoB::SubjectParser
  # * [subject_encoding] String subject.txtのエンコーディング(iconv用)
  # * [data_directory_path] Pathname データ保存用ディレクトリ(相対パス)
  # * [system] configuration,output(view)メソッドを提供するオブジェクト
  module BoardHandler
    BoardInfo = Struct.new(:url)
    
    def get_subjects()
      get_subject_parser.parse(subject_source)
    end
    
    def index_file
      data_directory + data_directory_path + "index.marshal"
    end
    
    def index_manager
      TwoB::Marshaler.new(index_file, Hash.new)
    end
    
    def data_directory
      system.configuration.data_directory
    end
    
    def list_thread()
      board = BoardInfo.new(original_url)
      subjects = get_subjects()
      index_map = index_manager.load()
      threads = subjects.collect do |subject_item|
        TwoB::ThreadSubject.new(subject_item, index_map.fetch(subject_item.number, 0))
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
