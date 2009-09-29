require 'twob/handler'
require 'twob/subject'
require 'jbbs/thread/thread_service'
require 'twob/subject_parser'
require 'twob/board_handler'
require 'twob/read_counter'
require 'board_view'
require 'forwardable'

module JBBS
  class BoardService
    extend Forwardable
    
    def initialize(category, number)
      @category = category
      @number = number
    end
    
    attr_reader :category, :number
    
    def host
      category.host
    end
    
    include TwoB::Handler
    
    include TwoB::ReadCounter
    
    def get_child(value)
      JBBS::ThreadService.new(self, value)
    end
    
    def execute(request, value)
      list_thread()
    end
    
    
    include TwoB::BoardHandler
    
    def original_url
      "http://#{host.name}/#{category.name}/#{number}/"
    end
    
    def subject_source
      HTTPGetSource.new(host.name, "/#{category.name}/#{number}/subject.txt", {}, subject_encoder, "\n")
    end

    def subject_url
      original_url + "subject.txt"
    end

    def get_subject_parser()
      TwoB::SubjectParser.new(/^(\d+)\.cgi,(.+)\((\d+)\)$/)
    end

    def subject_encoder
      Encoder.by_name("EUC-JP-MS")
    end
    
    def data_directory_path
      Pathname.new(category.host.name) + category.name + number
    end
    
    def system
      category.host.system
    end
  end
end
