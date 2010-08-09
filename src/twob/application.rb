require 'twob/root_handler'
require 'twob/backend'
require 'twob/configuration'
require 'pathname'

module TwoB
  class Application
    def initialize(frontend, request, backend = TwoB::Backend.new)
      @frontend = frontend
      @backend = backend
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
      TwoB::RootHandler.new(self.configuration, @backend)
    end

    def configuration
      TwoB::Configuration.new(Pathname.new(@frontend.data_directory).expand_path)
    end
  end
end