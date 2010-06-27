# -*- coding: utf-8 -*-

require 'twob/thread'
require 'bbs2ch/thread/dat_line'

module BBS2ch
  class DatParser < TwoB::Dat::DatParser
    include TwoB::Dat
    
    # ex. "2008/08/18(月) 10:10:53 ID:sgrp3MC1 BE:1086480184-2BP(0)"
    DATE_PATTERN = /\A(.*?)( ID:(\S+))?( BE:(.*))?\z/
    
    def initialize(initial_number = 1)
      super()
      @number = initial_number
    end
    
    def on_start_part(part)
      @number = part.number_from
    end
    
    def parse_line(values, &block)
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
      self.thread_title = values.fetch(4, "") if @number == 1
      line = BBS2ch::DatLine.new(@number, name, trip, mail, date, id, be, parse_body(body_text))
      @res_list << line if block.nil? || block.call(line)
      @number += 1
      line
    end
  end
end
