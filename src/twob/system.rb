require 'twob/handler'
require 'bbs2ch/host'
require 'jbbs/host'

module TwoB
  class System
    include Handler
    
    def initialize(configuration)
      @configuration = configuration
    end
    
    attr_reader :configuration
    
    def get_child(value)
      case value
      when JBBS::Host::Name then JBBS::Host.new(self)
      when BBS2ch::Host.NamePattern then BBS2ch::Host.new(self, value)
      else self
      end
    end
  end
end
