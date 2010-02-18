# -*- coding: utf-8 -*-

module TwoB
  module Dat
    class Content
      def initialize(title, res_list)
        @title = title
        @res_list = res_list
      end
      
      attr_reader :title, :res_list
      
      Empty = self.new(nil, [])
      
      def +(other_content)
        title = self.title ? self.title : other_content.title
        res_list = self.res_list + other_content.res_list
        Content.new(title, res_list)
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
  end
end
