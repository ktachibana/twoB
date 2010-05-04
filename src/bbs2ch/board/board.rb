require 'bbs2ch/thread'
require 'twob'
require 'io/source'
require 'encoder'
require 'pathname'

module BBS2ch
  class Board
    def initialize(host, id)
      @host = host
      @id = id
    end
    
    attr_reader :host, :id
    
    include TwoB::ReadCounter
    
    include TwoB::BoardHandler
    
    def get_child(value)
      BBS2ch::ThreadService.new(self, value)
    end
    
    def original_url
      "http://#{host.name}/#{id}/"
    end
    
    def subject_url
      "http://#{host.name}/#{id}/subject.txt"
    end
    
    def get_subject_parser()
      TwoB::SubjectParser.new(/^(\d+)\.dat<>(.+) \((\d+)\)$/)
    end

    def subject_path
      "/#{id}/subject.txt"
    end
    
    def subject_encoding
      "Windows-31J"
    end
    
    def subject_line_delimiter
      "\n"
    end
    
    def data_directory_path
      Pathname.new(host.name) + id
    end
    
    def system
      host.system
    end
  end
end
