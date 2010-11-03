require 'equality'

module TwoB
  class ThreadSubject
    Item = Struct.new(:order, :number, :title, :res_count)
    def initialize(content, read_count)
      @content = content
      @read_count = read_count
    end

    equality :@content, :@read_count

    def order
      @content.order
    end

    def number
      @content.number
    end

    def title
      @content.title
    end

    def read?
      @read_count.nonzero?
    end

    def res_count
      @content.res_count
    end

    def read_count
      @read_count
    end

    def new_count
      read_count != 0 ? res_count - read_count : 0
    end

    def has_new?
      new_count.nonzero?
    end
  end
end