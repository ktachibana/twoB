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

    def self.get_path(url)
      match = %r|http\://(\w+\.2ch\.net)/test/read\.cgi/(\w+)/(\w+)/(.*)|.match(url)
      match ? "/#{match[1]}/#{match[2]}/#{match[3]}/#{match[4]}#firstNew" : nil
    end

    def /(value)
      Board.new(self, value)
    end
  end
end
