# -*- coding: utf-8 -*-

module TwoB
  module Dat
    class Line
      def initialize(number, name, trip, mail, date, id, body)
        @number = number
        @name = name
        @trip = trip
        @mail = mail
        @date = date
        @id = id
        @body = body
      end

      attr_reader :number, :name, :trip, :mail, :date, :id, :body

      def has_trip?
        !trip.nil?
      end

      def age?()
        !mail.include?("sage")
      end
    end
  end
end