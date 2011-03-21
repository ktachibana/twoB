# -*- coding: utf-8 -*-

require 'twob/thread'
require 'jbbs/thread'
require 'forwardable'

module JBBS
  class BoardService
    extend Forwardable
    def initialize(category, number)
      @category = category
      @number = number
    end

    attr_reader :category, :number

    def host
      category.host
    end

    include TwoB::BoardHandler

    def /(value)
      JBBS::ThreadService.new(self, value)
    end

    def original_url
      "http://#{host.name}/#{category.name}/#{number}/"
    end

    def subject_url
      original_url + "subject.txt"
    end

    def get_subject_parser()
      TwoB::SubjectParser.new(/^(\d+)\.cgi,(.+)\((\d+)\)$/)
    end

    def subject_path
      "/#{category.name}/#{number}/subject.txt"
    end

    def subject_encoding
      "EUC-JP-MS"
    end

    def subject_line_delimiter
      "\n"
    end

    def data_directory_path
      Pathname.new(host.name) + category.name + number
    end

    def system
      host.system
    end
  end
end
