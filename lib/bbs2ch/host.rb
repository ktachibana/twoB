require 'framework/handler'
require 'bbs2ch/board'

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

    URLPattern = PatternMap.new
    URLPattern.map(%r|http\://(\w+\.2ch\.net)/test/read\.cgi/(\w+)/(\w+)/(.*)|) do |match|
      "/#{match[1]}/#{match[2]}/#{match[3]}/#{match[4]}#firstNew"
    end
    URLPattern.map(%r|http\://(\w+\.2ch\.net)/(\w+)/|) do |match|
      "/#{match[1]}/#{match[2]}/"
    end

    def self.get_path(url)
      URLPattern.get(url)
    end

    def /(value)
      Board.new(self, value)
    end
  end
end
