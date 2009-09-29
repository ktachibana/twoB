require 'twob/handler'
require 'redirect_response'

module BBS2ch
  class Res
    include TwoB::Handler
    
    def initialize(thread, number)
      @thread = thread
      @number = number
    end
    
    attr_reader :thread, :number
    
    def system
      thread.system
    end
    
    def execute(value)
      case value
      when /bookmark/
        bookmark()
      end
    end
    
    def bookmark()
      thread.update_bookmark_number(number)
      RedirectResponse.new("../")
    end
  end
end
