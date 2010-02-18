# -*- coding: utf-8 -*-
require 'twob/thread/dat/dat_body'

module TwoB
  module Dat
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
