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

    def self.get_path(url)
      match = %r|http\://jbbs\.livedoor\.jp/bbs/read\.cgi/(\w+)/(\w+)/(\w+)/(.*)|.match(url)
      match ? "/jbbs.livedoor.jp/#{match[1]}/#{match[2]}/#{match[3]}/#{match[4]}#firstNew" : nil
    end

    def name
      Name
    end

    def /(value)
      Category.new(self, value)
    end
  end
end
