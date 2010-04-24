require 'twob'
require 'bbs2ch'

module BBS2ch
  def access_thread(path, param = {})
    @request = TwoB::Request.new("/server.2ch.net/board/123/#{path}", param)
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    @thread = @response.document
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
  end
  
  def view_thread(delta_input)
    BBS2ch::ThreadService.__send__(:define_method, :get_new_input) do |request|
      delta_input
    end
    access_thread("l50#firstNew")
  end
  
  def view_res_anchor(picker_string)
    access_thread("res_anchor", {"range" => [picker_string]})
  end
end
