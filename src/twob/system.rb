require 'twob/handler'
require 'bbs2ch/host'
require 'jbbs/host'
require 'twob/error_view'

module TwoB
  class System
    include Handler
    
    def initialize(configuration)
      @configuration = configuration
    end
    
    attr_reader :configuration
    
    def process
      begin
        request = get_request
        response = apply(request, request.path_info)
      rescue Exception => e
        handle_error(e)
      else
        output(response)
      end
    end
    
    def handle_error(e)
      output(ErrorView.new(e))
    end
    
    def get_child(value)
      case value
      when JBBS::Host::Name then JBBS::Host.new(self)
      when BBS2ch::Host.NamePattern then BBS2ch::Host.new(self, value)
      else self
      end
    end
  end
end
