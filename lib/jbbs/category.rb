require 'framework/handler'
require 'jbbs/board'

module JBBS
  class Category
    include TwoB::Handler
    def initialize(host, name)
      @host = host
      @name = name
    end

    attr_reader :host, :name

    def /(value)
      BoardService.new(self, value)
    end
  end
end
