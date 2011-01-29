# -*- coding: utf-8 -*-
require 'util'
require 'twob/thread/picker'
require 'forwardable'

module TwoB
  class Thread
    include Enumerable
    def initialize(thread, caches, delta, picker, metadata)
      @thread = thread
      @caches = caches
      @delta = delta
      @picker = picker
      @metadata = metadata
    end

    attr_reader :thread, :caches, :delta, :metadata

    def title
      @caches.each{|cache| return cache.title if cache.has_title? }
      @delta.title
    end

    def original_url
      @thread.original_url
    end

    def dat_url
      @thread.dat_url
    end

    def [](number)
      find do |res|
        res.number == number
      end
    end

    class Templates
      def initialize
        @templates = {}
      end

      def match(key, &template)
        @templates[key] = template
      end

      def do_apply(key, *object)
        @templates[key].call(*object) if @templates.include?(key)
      end
    end

    class Gap
      def initialize(prev_range, next_range)
        @prev_range, @next_range = prev_range, next_range
      end

      def shrink_last(size)
        shurinked = @next_range.first - size
        (shurinked > @prev_range.last+1) ? shurinked : @prev_range.first
      end
    end

    def each_item
      templates = Templates.new
      yield templates

      @caches.each_with_index do |cache, index|
        cache.each_res do |res|
          templates.do_apply(:res, Res.new(res, unread?(res)))
        end
        if index < (@caches.length - 1)
          next_cache = @caches[index+1]
          templates.do_apply(:gap, Gap.new(cache.range, next_cache.range))
        end
      end
      return if @delta.empty?
      templates.do_apply(:border)
      @delta.each_res do |res|
        templates.do_apply(:res, Res.new(res, true))
      end
    end

    def each_res
      @caches.each do |cache|
        cache.each_res do |res|
          yield Res.new(res, unread?(res))
        end
      end
      @delta.each_res do |res|
        yield Res.new(res, true)
      end
    end
    alias :each :each_res

    def visible_all?(anchor)
      ranges.include_range?(anchor.range)
    end

    def ranges
      @picker.to_ranges(@metadata.last_res_number, @delta.last_res_number, bookmark_number)
    end
    private :ranges

    def res_count
      @caches.sum{|cache| cache.res_count } + delta.res_count
    end

    def last_res_number
      @delta.empty? ? @caches.last.last_res_number : @delta.last_res_number
    end

    def has_new?
      !@delta.empty? || bookmarking?
    end

    def bookmarking?
      !@metadata.bookmark_number.nil?
    end

    def bookmark_number
      @metadata.bookmark_number
    end

    def unread?(res)
      bookmarking? ? res.number > bookmark_number : false;
    end

    def first_new_number
      bookmarking? ? bookmark_number + 1 : @cache.res_count + 1
    end

    def read_number
      bookmarking? ? bookmark_number : @metadata.last_res_number
    end
  end

  #= レスの>>1-50とかの並び。>>1とか一個しかなくても並び
  class ResSequence
    def initialize(res_seq, is_new)
      @res_seq = res_seq
      @is_new = is_new
    end

    attr_reader :res_seq

    # このレス群は新着？
    def new?
      @is_new
    end
  end

  class Res
    extend Forwardable
    def initialize(dat_res, is_new)
      @dat_res = dat_res
      @is_new = is_new
    end

    def_delegators :@dat_res, :number, :name, :has_trip?, :trip, :mail, :age?, :date, :id, :body

    def new?() @is_new end
  end
end
