# -*- coding: utf-8 -*-
require 'twob/thread/dat/dat_line'
require 'twob/thread/dat/dat_content'
require 'twob/thread/dat/dat_body_parser'

module BBS2ch
  DATE_PATTERN = /\A(.*?)( ID:(\S+))?( BE:(.*))?\z/
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
