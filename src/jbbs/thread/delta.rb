require 'io/source'
require 'encoder'

module JBBS
  class Delta
    def initialize(dat_content, bytes, index)
      @dat_content = dat_content
      @bytes = bytes
      @index = index
    end
    
    attr_reader :bytes, :dat_content
    
    def index
      @index
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
    
    def empty?
      @dat_content.empty?
    end
    
    def last_number
      empty? ? nil : @dat_content.last_res_number
    end
    
    def range
      @dat_content.range
    end
  end
end
