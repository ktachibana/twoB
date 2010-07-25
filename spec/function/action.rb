require 'twob'
require 'bbs2ch'

module TwoB::Spec
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end

  def access(path, param = {}, env = {"SCRIPT_NAME" => "/twoB/action", "REQUEST_URI" => "http://192.168.0.6/twoB/action" + path}, &block)
    @request = TwoB::Request.new(path, param, env)
    @system = SpecSystem.new(@request)
    block.call(@system) if block
    @system.process
    @response = @system.response
  end
end
