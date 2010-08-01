require 'spec_context'

module TwoB
  module Spec
    def valid_response
      @response.status_code.should == 200
      @response.content_type.should == "text/html; charset=UTF-8"
    end

    def access(path, param = {}, &block)
      @request = SpecRequest.new(path, param)
      @frontend = SpecFrontend.new
      @backend = SpecBackend.new
      block.call(@backend) if block
      @frontend.access(@request, @backend)
      @response = @frontend.response
    end
  end
end
