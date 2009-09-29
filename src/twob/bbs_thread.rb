require 'enum_util'
require 'twob/picker'
require 'forwardable'

module TwoB
  class Thread
    def initialize(thread, cache, delta, picker, option)
      @thread = thread
      @cache = cache
      @delta = delta
      @picker = picker
      @option = option
    end
    
    attr_reader :thread, :option
  
    def title
      return @cache.title unless @cache.title
      return @delta.title
    end
  
    def original_url
      @thread.original_url
    end
  
    def each_all_res
      @cache.each_res do |res|
        yield Res.new(res, unread?(res), picked?(res))
      end
      @delta.each_res do |res|
        yield Res.as_new(res)
      end
    end
    
    def picked?(res)
      @picker.include?(res.number, res_count)
    end

    def each_visible_res
      each_all_res do |res|
        yield res if res.visible?
      end
    end

    def visible_all?(anchor)
      visible_picker.include_range?(anchor.range)
    end
    
    def visible_picker
      ranges = @picker.to_ranges(res_count)
      ranges << @delta.range unless @delta.empty?
      Picker::Composite.compose(*ranges)
    end
    
    def res_count
      @cache.res_count + @delta.res_count
    end
    
    def last_res_number
      [@delta.last_number, @cache.last_number].find do |last_number|
        last_number
      end
    end
  
    def has_new?
      !@delta.empty? || bookmarking?
    end
  
    def bookmarking?
      !@option.bookmark_number.nil?
    end
  
    def bookmark_number
      @option.bookmark_number
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
  
  ThreadOption = Struct.new(:bookmark_number)
  def ThreadOption.empty
    ThreadOption.new(nil)
  end

  class Res
    extend Forwardable
    
    def initialize(dat_res, is_new, is_visible)
      @dat_res = dat_res
      @is_new = is_new
      @is_visible = is_visible
    end
    
    def self.as_new(dat_res)
      self.new(dat_res, true, true)
    end
    
    def self.as_cache(dat_res)
      self.new(dat_res, false, true)
    end
    
    def_delegators :@dat_res, :number, :name, :has_trip?, :trip, :mail, :age?, :date, :id, :body

    def new?() @is_new end
    def visible?() @is_visible end
  end
end
