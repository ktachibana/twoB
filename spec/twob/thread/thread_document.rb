# -*- coding: utf-8 -*-

class ThreadDocument
  def initialize(html_string)
    @document = Nokogiri::HTML(html_string)
  end
  
  def title
    @document.css("title").text
  end
  
  def has_new?
    !@document.css(".new").empty?
  end
  
  def [](n)
    Res.new(res_node(n))
  end
 
  def res_node(n)
    @document.css("\#_#{n}")
  end
  private :res_node
  
  
  class Res
    def initialize(res_node)
      @res = res_node
    end
    
    def exist?
      !@res.empty?
    end
    
    def new?
      !@res.css(".new").empty?
    end
  end
end

