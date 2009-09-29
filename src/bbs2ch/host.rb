require 'twob/handler'
require 'bbs2ch/board/board'

module BBS2ch
  class Host
    include TwoB::Handler
    
    def self.NamePattern
      /\w+\.2ch\.net/
    end
    
    def initialize(system, name)
      @system = system
      @name = name
    end
    
    attr_reader :system, :name
    
    def get_child(value)
      Board.new(self, value)
    end
  end
end
