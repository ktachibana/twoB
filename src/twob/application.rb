require 'twob/system'
require 'twob/configuration'
require 'pathname'

module TwoB
  class Application
    def initialize(frontend, request)
      @frontend = frontend
      @request = request
    end

    def main
      begin
        response = root_handler.apply(@request, @request.path_info)
      rescue Exception => e
        @frontend.handle_error(e)
      else
        @frontend.output(response)
      end
    end
    
    def root_handler
      TwoB::System.new(TwoB::Configuration.new(Pathname.new(@frontend.data_directory).expand_path))
    end
  end
end