require 'bbs2ch/thread/dat'
require 'twob/dat_body'
require 'time'
require 'source'

module BBS2ch
  class Cache
    def initialize(dat_content, dat_source)
      @dat_content = dat_content
      @dat_source = dat_source
    end
    
    attr_reader :dat_content, :dat_source
    
    Empty = self.new(BBS2ch::Dat.new([]), nil)
    
    def empty?
      dat_content.empty?
    end
    
    def dat_size
      dat_source.path.size
    end
    
    def last_modified
      dat_source.path.mtime
    end
    
    def dat_header
      header = {}
      return header if empty?
      header["Range"] = "bytes=#{dat_size}-" unless dat_size.zero?
      header["If-Modified-Since"] = last_modified.httpdate if last_modified
      header
    end
    
    def new_number()
      empty? ? 1 : dat_content.last_res_number + 1      
    end
    
    def append(new_dat_content, timestamp)
      Cache.new(@dat_content + new_dat_content, timestamp.httpdate)
    end
    
  end
end