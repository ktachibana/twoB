# -*- coding: utf-8 -*-
require 'twob/thread/dat/dat_line'
require 'twob/thread/dat/dat_content'
require 'twob/thread/dat/dat_body_parser'

module JBBS
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
