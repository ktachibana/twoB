# -*- coding: utf-8 -*-
require 'twob'

module TwoB
  class ResService
    include TwoB::Handler
    
    def initialize(thread, number)
      @thread = thread
      @number = number
    end
    
    attr_reader :thread, :number
    
    def system
      @thread.system
    end
    
    def execute(request, value)
      case value
      when /^bookmark$/
        bookmark()
      end
    end
    
    def bookmark()
      @thread.update_bookmark_number(number)
      RedirectResponse.new("../l50")
    end
  end
end
