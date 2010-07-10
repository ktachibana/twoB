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
        to_ranges(cached_number, max_number, bookmark_number).limit(cached_number)
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
        Ranges.union(1..1, base_number - @cache_count + 1 .. max_number)
      end

      def build_thread(builder)
        base_number = builder.bookmark_number ? builder.bookmark_number : builder.cached_number
        ranges = Ranges.union(1..1, base_number - @cache_count + 1 .. builder.cached_number)
        builder.load_cache(*ranges.limit_range(1..builder.cached_number))
        builder.load_delta
        builder.update
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
        ranges = Ranges.new
        ranges << (1..1) if @include_1
        ranges << ([1, max_number - @count + 1].max .. max_number)
        ranges.union
      end

      def build_thread(builder)
        delta = builder.load_delta
        ranges = Ranges.new
        ranges << (1..1) if @include_1
        ranges << (delta.last_res_number - @count + 1 .. builder.cached_number)
        builder.load_cache(*ranges)
      end

      def to_s
        "l#{count}" + (@include_1 ? "" : "n")
      end
    end

    class All < Picker
      include Singleton
      def to_ranges(cached_number, max_count, bookmark_number = nil)
        Ranges.new(1..max_count)
      end

      def build_thread(builder)
        build.load_cache(1..builder.cached_number)
        build.load_delta
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

      def build_thread(builder)
        builder.load_cache(@number..@number)
        builder.load_delta do |res|
          res.number == @number
        end
      end
      
      def build_anchor(builder)
        builder.load_cache(@number..@number)
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

      def build_thread(builder)
        builder.load_cache(@range)
        builder.load_delta do |res|
          @range.include?(res.number)
        end
      end
      
      def build_anchor(builder)
        builder.load_cache(@range)
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

      def build_thread(builder)
        builder.load_cache(@from..builder.cached_number)
        builder.load_delta do |res|
          @from <= res.number
        end
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

      def build_thread(builder)
        builder.load_cache(1..@to)
        builder.load_delta do |res|
          res.number <= @to
        end
      end

      def to_s
        "-#{to}"
      end
    end
  end
end
