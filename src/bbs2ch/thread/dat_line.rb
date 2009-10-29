# -*- coding: utf-8 -*-

module BBS2ch
  class DatLine
    def initialize(number, name, trip, mail, date, id, be, body)
      @number = number
      @name = name
      @trip = trip
      @mail = mail
      @date = date
      @id = id
      @be = be
      @body = body
    end
    
    attr_reader :number, :name, :trip, :mail, :date, :id, :be, :body
    
    def has_trip?
      !trip.nil?
    end

    def age?()
      !mail.include?("sage")
    end
  end
  
end