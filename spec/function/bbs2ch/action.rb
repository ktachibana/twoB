require 'action'

module BBS2ch::Spec
  include TwoB::Spec
  def view_thread_list(subject_source)
    access("/server.2ch.net/board/") do |backend|
      backend.stub!(:get_subject_source).and_return(subject_source)
    end
  end

  def view_thread(delta_input, picker_string = "subscribe5")
    access("/server.2ch.net/board/123/#{picker_string}#firstNew") do |backend|
      backend.stub!(:get_bytes).and_return(delta_input.read)
    end
    @thread = @response.as_thread
  end

  def view_res_anchor(picker_string)
    access("/server.2ch.net/board/123/res_anchor", "picker" => [picker_string])

    @thread = @response.as_thread
  end

  def bookmark_res(res_number)
    access("/server.2ch.net/board/123/#{res_number}/bookmark")
  end
end
