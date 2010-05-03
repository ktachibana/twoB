require 'twob'
require 'bbs2ch'

module BBS2ch
  def valid_response
    @response.status_code.should == 200
    @response.content_type.should == "text/html; charset=UTF-8"
  end
  
  def access(path, param = {})
    @request = TwoB::Request.new("/server.2ch.net/board/#{path}", param)
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
  end
  
  def access_thread(path, param = {})
    access("123/#{path}", param)
    @thread = @response.as_thread
  end
  
  def view_thread_list(subject_source)
    BBS2ch::Board.__send__(:define_method, :subject_source) do
      subject_source
    end
    @request = TwoB::Request.new("/server.2ch.net/board/")
    @system = SpecSystem.new(@request)
    @system.process
    @response = @system.response
    @board_dir = SpecSystem::SpecConfiguration.data_directory + "server.2ch.net" + "board"
  end
  
  def view_thread(delta_input, picker_string = "l50")
    BBS2ch::ThreadService.__send__(:define_method, :get_new_input) do |request|
      delta_input
    end
    access_thread("#{picker_string}#firstNew")
  end
  
  def view_res_anchor(picker_string)
    access_thread("res_anchor", {"range" => [picker_string]})
  end
  
  def bookmark_res(res_number)
    access("123/#{res_number}/bookmark")
  end
end
