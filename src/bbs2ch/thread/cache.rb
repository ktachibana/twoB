# -*- coding: utf-8 -*-
require 'time'
require 'io/source'
require 'twob/thread'

module BBS2ch
  class Cache
    def initialize(dat_content)
      @dat_content = dat_content
    end
    
    attr_reader :dat_content
    
    Empty = self.new(TwoB::Dat::Content::Empty)
    
    def empty?
      dat_content.empty?
    end
    
    def append(new_dat_content, timestamp)
      Cache.new(@dat_content + new_dat_content, timestamp.httpdate)
    end
    
    def new_number
      empty? ? 1 : dat_content.last_res_number + 1      
    end
    
    def title
      @dat_content.title
    end
    
    def each_res
      @dat_content.each_res do |res|
        yield res
      end
    end

    def res_count
      @dat_content.res_count
    end
    
    def last_number
      @dat_content.last_res_number
    end
    
    def range
      @dat_content.range
    end
  end
end
