require 'twob'
require 'jbbs/thread/thread_service'
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
    
    include TwoB::ReadCounter
    
    
    include TwoB::BoardHandler
    
    def get_child(value)
      JBBS::ThreadService.new(self, value)
    end
    
    def original_url
      "http://#{host.name}/#{category.name}/#{number}/"
    end
    
    def subject_source
      request = HTTPRequest.new(host.name, "/#{category.name}/#{number}/subject.txt", {})
      HTTPGetSource.new(request, subject_encoder, "\n")
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
