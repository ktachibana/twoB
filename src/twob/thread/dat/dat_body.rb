# -*- coding: utf-8 -*-

module TwoB
  module Dat
    class Text
      def initialize(text)
        raise if text.nil?
        @text = text
      end
    
      def body_type
        :text
      end
    
      def to_s
        @text
      end
    
      def ==(other)
        to_s == other.to_s
      end
    end
    
    class Anchor
      PATTERN = /\>\>?(\d+)(\-(\d+))?/
      
      def initialize(anchor_str)
        @anchor_str = anchor_str
        match = PATTERN.match(@anchor_str)
        @first_id = match[1].to_i
        @last_id = match[3] ? match[3].to_i : nil
        @values = [@first_id, @last_id].compact
        raise anchor_str unless @values
      end
    
      attr_reader :first_id, :last_id
      
      def top_id
        @values.min
      end
      
      def bottom_id
        @values.max
      end
      
      def range
        top_id..bottom_id
      end
      
      def visible?(thread_range)
        
      end
    
      def body_type
        :anchor
      end
    
      def to_s
        @anchor_str
      end
    
      def ==(other)
        to_s == other.to_s
      end
    end
    
    class Link
      def initialize(text, url)
        @text = text
        @url = url
      end
    
      def body_type
        :link
      end
    
      def url
        @url
      end
    
      def link_type
        unless url.match(/^.+\.(jpeg|jpg|gif|png|bmp|jp2)$/i).nil?
          return :image
        else
          return nil
        end
      end
    
      def to_s
        @text
      end
    
      def ==(other)
        to_s == other.to_s && url == other.url
      end
    end
    
    class BreakLine
      def body_type
        :break_line
      end
    
      def ==(other)
        is_a?(other.class)
      end
    end
  end
end
