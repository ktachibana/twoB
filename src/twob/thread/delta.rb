require 'io/source'
require 'encoder'

module TwoB
  class Delta
    def initialize(dat_content, base_res_number, bytes, index)
      @dat_content = dat_content
      @base_res_number = base_res_number
      @bytes = bytes
      @index = index
    end
    
    attr_reader :dat_content, :base_res_number, :bytes, :index
    
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
    
    def empty?
      @dat_content.empty?
    end
    
    def last_res_number
      @dat_content.empty? ? @base_res_number : @dat_content.last_res_number
    end
    
    def range
      @dat_content.range
    end
  end
end
