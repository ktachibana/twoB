# -*- coding: utf-8 -*-

class ThreadDocument
  def initialize(html_string)
    @document = Nokogiri::HTML(html_string)
  end

  attr_reader :document

  def title
    @document.css("title").text
  end

  def dat_link
    @document.css("#view_dat_file")
  end

  def has_new?
    !@document.css(".new").empty?
  end

  def [](n)
    Res.new(@document.css("\#_#{n}"), n)
  end

  def res_ranges
    numbers = @document.css(".res").collect do |res|
      res["id"].delete("_").to_i
    end
    return [] if numbers.empty?

    result = []
    i = 0
    first = numbers[i]
    while i + 1 < numbers.length
      if numbers[i+1] - numbers[i] > 1
        result << (first..numbers[i])
        first = numbers[i+1]
      end
      i += 1
    end
    result << (first..numbers[i])
    result
  end

  class Res
    def initialize(res_node, number)
      @res = res_node
      @number = number
    end

    def date
      @res.css(".date").text
    end

    def id
      @res.css(".id").text
    end

    def exist?
      !@res.empty?
    end

    def new?
      raise "res[#{@number}] not exist" unless exist?
      !@res.css(".new").empty?
    end
  end
end

