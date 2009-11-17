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
  
  
  class Res
    def initialize(res_node, number)
      @res = res_node
      @number = number
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

