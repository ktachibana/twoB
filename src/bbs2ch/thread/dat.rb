# -*- coding: utf-8 -*-

module BBS2ch
  class Dat
    def initialize(dat_lines)
      @dat_lines = dat_lines 
    end
    
    attr_reader :dat_lines
    
    def empty?
      dat_lines.empty?
    end
    
    def [](index)
      @dat_lines[index]
    end
    
    def res_list
      dat_lines
    end
    
    def res_count
      @dat_lines.size
    end
    
    def each_res
      @dat_lines.each do |i|
        yield i
      end
    end
    
    def first_res_number
      empty? ? nil : dat_lines.first.number
    end
    
    def last_res_number
      empty? ? nil : dat_lines.last.number
    end

    def title
      
    end
  end
end
