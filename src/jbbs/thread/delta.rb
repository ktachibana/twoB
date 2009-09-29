require 'source'
require 'encoder'

module JBBS
  class Delta
    def initialize(thread, thread_index, bytes)
      @thread_index = thread_index
      @bytes = bytes
      source = BytesSource.new(bytes, Encoder.by_name(thread.dat_encoding), "\n")
      @dat_parser = thread.get_dat_parser
      @dat_content = @dat_parser.parse(source)
    end
    
    attr_reader :bytes, :dat_content
    
    def index
      @dat_parser.index
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
      empty? ? @thread_index.last_res_number : @dat_content.last_res_number
    end
    
    def range
      @dat_content.range
    end
  end
end
