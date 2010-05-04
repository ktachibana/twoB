require 'action'

module BBS2ch::Spec
  include TwoB::Spec
  
  def view_thread_list(subject_source)
    access("/server.2ch.net/board/") do |system|
      system.stub!(:get_subject_source).and_return(subject_source)
    end
  end
  
  def view_thread(delta_input, picker_string = "l50")
    access("/server.2ch.net/board/123/#{picker_string}#firstNew") do |system|
      @system.stub!(:get_delta_input).and_return(delta_input)
    end
    @thread = @response.as_thread
  end
  
  def view_res_anchor(picker_string)
    access("/server.2ch.net/board/123/res_anchor", "range" => [picker_string])

    @thread = @response.as_thread
  end
  
  def bookmark_res(res_number)
    access("/server.2ch.net/board/123/#{res_number}/bookmark")
  end
end
