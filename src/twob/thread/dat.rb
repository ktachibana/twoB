# -*- coding: utf-8 -*-
require 'twob/thread/dat_body'

module TwoB
  class DatContent
    def initialize(title, res_list)
      @title = title
      @res_list = res_list
    end
    
    attr_reader :title, :res_list
    
    Empty = self.new(nil, [])
    
    def +(other_content)
      title = self.title ? self.title : other_content.title
      res_list = self.res_list + other_content.res_list
      DatContent.new(title, res_list)
    end
    
    def each_res
      @res_list.each do |res|
        yield res
      end
    end
    
    def res_count
      @res_list.size
    end
    
    def empty?
      @res_list.empty?
    end
    
    def range
      empty? ? nil : first_res_number..last_res_number
    end

    def first_res_number
      empty? ? nil : @res_list.first.number
    end
    
    def last_res_number
      empty? ? nil : @res_list.last.number
    end
  end
  
  class DatRes
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
  
  module Dat
    TRIP_PATTERN = /\A([^<]*)(<\/b>\s*◆(\S+)\s*<b>)?\z/

    URL_PATTERN = /(http|ttp|tp)(:\/\/[0-9a-zA-Z_\!-\&\+\-\.\/\:\;\=\?\@\[-\`\{-\~]+)/
    ANCHOR_PATTERN = /(<a .*?>)?((&gt;)?&gt;(\d+)(\-\d+)?)(<\/a>)?/
    BREAK_LINE_PATTERN = %r|<br( /)?>|
  
    def parse_body(body_str)
      builder = ItemBuilder.new(body_str)
      builder.mark_pattern(ANCHOR_PATTERN) do |match|
        Anchor.new(match[2].gsub("&gt;", ">"))
      end
      builder.mark_pattern(BREAK_LINE_PATTERN) do
        BreakLine.new()
      end
      builder.mark_pattern(URL_PATTERN) do |match|
        Link.new(match[0], "http" + match[2])
      end
      builder.build do |str|
        Text.new(str)
      end
    end

    class ItemBuilder
      BodyItem = Struct.new(:body, :range)
      
      def initialize(body_str)
        @body_str = body_str
        @marked_items = []
      end
      
      def mark_pattern(pattern, &to_item)
        i = 0
        while match = pattern.match(@body_str[i..-1])
          range = (match.begin(0) + i) ... (match.end(0) + i)
          item = to_item.call(match)
          @marked_items << BodyItem.new(item, range)
          i = i + match.end(0)
        end
      end
      
      def build(&to_default_item)
        items = @marked_items.sort{|a, b| a.range.begin <=> b.range.begin }
        
        result = []
        i = 0
        items.each do |item|
          result << to_default_item.call(@body_str[i...item.range.begin]) unless item.range.begin == i
          result << item.body
          i = item.range.end
        end
        result << to_default_item.call(@body_str[i..-1]) unless i == @body_str.size
        result
      end
    end
  end
end
