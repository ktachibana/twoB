# -*- coding: utf-8 -*-
require 'util'
require 'twob/thread/picker'
require 'forwardable'

module TwoB
  class Thread
    include Enumerable
    def initialize(thread, cache, delta, picker, metadata)
      @thread = thread
      @cache = cache
      @delta = delta
      @picker = picker
      @metadata = metadata
    end

    attr_reader :thread, :metadata

    def title
      (@cache.has_title? ? @cache : @delta).title
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

    def each_item
      templates = Templates.new
      yield templates

      @cache.each_res do |res|
        templates.do_apply(:res, Res.new(res, unread?(res)))
      end
      return if @delta.empty?
      templates.do_apply(:border)
      @delta.each_res do |res|
        templates.do_apply(:res, Res.new(res, true))
      end
    end

    def each_res
      @cache.each_res do |res|
        yield Res.new(res, unread?(res))
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
      @cache.res_count + @delta.res_count
    end

    def last_res_number
      @delta.empty? ? @cache.last_number : @delta.last_res_number
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
