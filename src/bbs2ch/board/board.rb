require 'bbs2ch/thread/thread'
require 'twob/handler'
require 'twob/board/subject_parser'
require 'twob/board/board_handler'
require 'twob/read_counter'
require 'twob/board/board_view'
require 'io/source'
require 'pathname'

module BBS2ch
  class Board
    def initialize(host, id)
      @host = host
      @id = id
    end
    
    attr_reader :host, :id
    
    
    include TwoB::Handler
    
    include TwoB::ReadCounter
    
    def get_child(value)
      BBS2ch::Thread.new(self, value)
    end
    
    def execute(request, value)
      list_thread()
    end
    
    
    include TwoB::BoardHandler
    
    def original_url
      "http://#{host.name}/#{id}/"
    end
    
    def subject_url
      "http://#{host.name}/#{id}/subject.txt"
    end
    
    def subject_source
      request = HTTPRequest.new(host.name, "/#{id}/subject.txt", {})
      HTTPGetSource.new(request, subject_encoding, "\n")
    end
    
    def get_subject_parser()
      TwoB::SubjectParser.new(/^(\d+)\.dat<>(.+) \((\d+)\)$/)
    end

    def subject_encoding
      "Windows-31J"
    end
    
    def data_directory_path
      Pathname.new(host.name) + id
    end
    
    def system
      host.system
    end
  end
end
