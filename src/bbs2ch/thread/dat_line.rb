# -*- coding: utf-8 -*-
require 'twob/thread'

module BBS2ch
  class DatLine < TwoB::Dat::Line
    def initialize(number, name, trip, mail, date, id, be, body)
      super(number, name, trip, mail, date, id, body)
      @be = be
    end
    
    attr_reader :be
  end
end