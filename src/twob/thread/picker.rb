require 'singleton'
require 'util'
require 'pattern_map'

module TwoB
  Pickers = PatternMap.new
  Pickers.map(/^l(\d+)(n)?$/) do |match|
    Picker::Latest.new(match[1].to_i, match[2].nil?)
  end
  Pickers.map(/^$/) do |match|
    Picker::All.instance
  end
  Pickers.map(/^(\d+)$/) do |match|
    Picker::Only.new(match[1].to_i)
  end
  Pickers.map(/^(\d+)-(\d+)$/) do |match|
    Picker::FromTo.new(match[1].to_i..match[2].to_i)
  end
  Pickers.map(/^(\d+)\-$/) do |match|
    Picker::From.new(match[1].to_i)
  end
  Pickers.map(/^\-(\d+)$/) do |match|
    Picker::To.new(match[1].to_i)
  end
  
  
  module Picker
    class Composite
      def initialize(ranges)
        @ranges = ranges
      end
      
      def self.compose(*ranges)
        results = []
        ranges.each do |range|
          adjacent_index = nil
          results.each_with_index do |result, index|
            if range.adjacent_range?(result)
              adjacent_index = index
              break
            end
          end
          if adjacent_index
            results[adjacent_index] = results[adjacent_index].compose(range)
          else
            results << range
          end
        end
        self.new(results)
      end
      
      attr_reader :ranges
      
      def include_range?(range)
        @ranges.any? do |r|
          r.include_range?(range)
        end
      end
  
      def limitation(max)
        results = @ranges.collect { |range|
          range.first .. [range.last, max].min
        }.select { |range|
          range.first <= range.last
        }
        Composite.compose(*results)
      end
      
      def empty?
        @ranges.empty?
      end
      
      def ==(other)
        @ranges == other.ranges
      end
    end
    
    module Concretizable
      def concretize(max_count)
        Composite.compose(*self.to_ranges(max_count))
      end
    end
  
    class Latest
      include Concretizable
      
      def initialize(count, include_1)
        @count = count
        @include_1 = include_1
      end
    
      attr_reader :count, :include_1
    
      def include?(number, max_count)
        (@include_1 && number == 1) || (max_count - @count < number)
      end
      
      def to_ranges(max_count)
        begin_number = [1, max_count - @count + 1].max
        if include_1
          if begin_number == 2
            return [1..max_count]
          else
            return [1..1, begin_number..max_count]
          end
        else
          return [begin_number..max_count]
        end
      end
      
      def ==(other)
        self.count == other.count && self.include_1 == other.include_1
      end
      
      def to_s
        "l#{count}" + (include_1? ? "" : "n")
      end
    end
    
    class All
      include Singleton
      include Concretizable
  
      def include?(number, max_count)
        number_include?(number)
      end
      
      def to_ranges(max_count)
        [1..max_count]
      end
  
      def number_include?(number)
        true
      end
      
      def to_s
        ""
      end
    end
    
    class Only
      include Concretizable
      
      def initialize(number)
        @number = number
      end
    
      attr_reader :number
    
      def include?(number, max_count)
        number_include?(number)
      end
      
      def to_ranges(max_count)
        [number..number]
      end
  
      def number_include?(number)
        number == @number
      end
      
      def ==(other)
        self.number == other.number
      end
      
      def to_s
        "#{number}"
      end
    end
    
    class FromTo
      include Concretizable

      def initialize(range)
        @range = range
      end
    
      attr_reader :range
    
      def include?(number, max_count)
        number_include?(number)
      end
      
      def to_ranges(max_count)
        [range]
      end
  
      def number_include?(number)
        @range.include?(number)
      end
      
      def ==(other)
        self.range == other.range
      end
      
      def to_s
        "#{range.begin}-#{range.end}"
      end
    end
    
    class From
      include Concretizable

      def initialize(from)
        @from = from
      end
    
      attr_reader :from
    
      def include?(number, max_count)
        number_include?(number)
      end
      
      def to_ranges(max_count)
        [from..max_count]
      end
  
      def number_include?(number)
        @from <= number
      end
  
      def ==(other)
        self.from == other.from
      end
      
      def to_s
        "#{from}-"
      end
    end
    
    class To
      include Concretizable

      def initialize(to)
        @to = to
      end
    
      attr_reader :to
    
      def include?(number, max_count)
        number_include?(number)
      end
      
      def to_ranges(max_count)
        [1..to]
      end
  
      def number_include?(number)
        number <= @to
      end
  
      def ==(other)
        self.to == other.to
      end
      
      def to_s
        "-#{to}"
      end
    end
  end
end
