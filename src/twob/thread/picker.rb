require 'singleton'
require 'util'
require 'pattern_map'
require 'equality'

module TwoB
  Pickers = PatternMap.new
  Pickers.map(/^subscribe(\d+)$/) do |match|
    Picker::Subscribe.new(match[1].to_i)
  end
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
    class Picker
      def to_cache_ranges(cached_number, max_number, bookmark_number = nil)
        to_ranges(cached_number, max_number, bookmark_number).limitation(cached_number)
      end
    end

    class Subscribe < Picker
      attr_reader :cache_count
      equality :@cache_count
      
      def initialize(cache_count)
        @cache_count = cache_count
      end

      def to_ranges(cached_number, max_number, bookmark_number = nil)
        base_number = bookmark_number ? bookmark_number : cached_number
        Ranges.new(1..1, base_number - @cache_count + 1 .. max_number)
      end
      
      def to_s
        "subscribe#{@cache_count}"
      end
    end

    class Latest < Picker
      attr_reader :count, :include_1
      equality :@count, :@include_1
      
      def initialize(count, include_1)
        @count = count
        @include_1 = include_1
      end

      def to_ranges(cached_number, max_number, bookmark_number = nil)
        begin_number = [1, max_number - @count + 1].max
        if include_1
          if begin_number == 2
            return Ranges.new(1..max_number)
          else
            return Ranges.new(1..1, begin_number..max_number)
          end
        else
          return Ranges.new(begin_number..max_number)
        end
      end

      def to_s
        "l#{count}" + (include_1? ? "" : "n")
      end
    end

    class All < Picker
      include Singleton

      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(1..max_count)
      end

      def to_s
        ""
      end
    end

    class Only < Picker
      attr_reader :number
      equality :@number

      def initialize(number)
        @number = number
      end

      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(number..number)
      end

      def to_s
        "#{number}"
      end
    end

    class FromTo < Picker
      attr_reader :range
      equality :@range
      
      def initialize(range)
        @range = range.dup
      end

      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(range)
      end

      def to_s
        "#{range.begin}-#{range.end}"
      end
    end

    class From < Picker
      attr_reader :from
      equality :@from
      
      def initialize(from)
        @from = from
      end

      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(from..max_count)
      end

      def to_s
        "#{from}-"
      end
    end

    class To < Picker
      attr_reader :to
      equality :@to
      
      def initialize(to)
        @to = to
      end

      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(1..to)
      end

      def to_s
        "-#{to}"
      end
    end
  end
end
