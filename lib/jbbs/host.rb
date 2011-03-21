require 'framework/handler'
require 'jbbs/category'

module JBBS
  class Host
    include TwoB::Handler

    Name = "jbbs.livedoor.jp"
    def initialize(system)
      @system = system
    end

    attr_reader :system

    JBBSPath = PatternMap.new
    JBBSPath.map(%r[http\://jbbs\.livedoor\.jp/bbs/read\.cgi/(\w+)/(\w+)/(\w+)/(.*)]) do |match|
      "/jbbs.livedoor.jp/#{match[1]}/#{match[2]}/#{match[3]}/#{match[4]}#firstNew"
    end
    JBBSPath.map(%r[http\://jbbs\.livedoor\.jp/(\w+)/(\w+)/]) do |match|
      "/jbbs.livedoor.jp/#{match[1]}/#{match[2]}/"
    end

    def self.get_path(url)
      JBBSPath.get(url)
    end

    def name
      Name
    end

    def /(value)
      Category.new(self, value)
    end
  end
end
