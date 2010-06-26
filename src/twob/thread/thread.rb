# -*- coding: utf-8 -*-
require 'util'
require 'twob/thread/picker'
require 'forwardable'

module TwoB
  class Thread
    def initialize(thread, cache, delta, picker, index)
      @thread = thread
      @cache = cache
      @delta = delta
      @picker = picker
      @index = index
    end
    
    attr_reader :thread, :index

    def title
      return @cache.title if @cache.title
      return @delta.title
    end
  
    def original_url
      @thread.original_url
    end
    
    def dat_url
      @thread.dat_url
    end
  
    def each_res
      @cache.each_res do |res|
        yield Res.new(res, unread?(res))
      end
      @delta.each_res do |res|
        yield Res.new(res, true)
      end
    end
    
    def visible_all?(anchor)
      ranges.include_range?(anchor.range)
    end
    
    def ranges
      @picker.to_ranges(@index.last_res_number, @delta.last_res_number, bookmark_number)
    end
    private :ranges
    
    def res_count
      @cache.res_count + @delta.res_count
    end
    
    def last_res_number
      @delta.last_res_number
    end

    def has_new?
      !@delta.empty? || bookmarking?
    end
  
    def bookmarking?
      !@index.bookmark_number.nil?
    end
  
    def bookmark_number
      @index.bookmark_number
    end
  
    def unread?(res)
      bookmarking? ? res.number > bookmark_number : false;
    end
  
    def first_new_number
      bookmarking? ? bookmark_number + 1 : @cache.res_count + 1
    end
    
    def read_number
      bookmarking? ? bookmark_number : @cache.last_number
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
