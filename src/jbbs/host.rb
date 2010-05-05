require 'twob/handler'
require 'jbbs/category'

module JBBS
  class Host
    include TwoB::Handler
    
    Name = "jbbs.livedoor.jp"
    
    def initialize(system)
      @system = system
    end
    
    attr_reader :system
    
    def name
      Name
    end
    
    def /(value)
      Category.new(self, value)
    end
  end
end
