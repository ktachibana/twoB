# -*- coding: utf-8 -*-

module JBBS
  class ThreadKey
    def initialize(board, number)
      @board = board
      @number = number
    end
    
    attr_reader :board, :number
    
    def system
      host.system
    end
    
    def category
      board.category
    end
    
    def host
      category.host
    end
  end
end
