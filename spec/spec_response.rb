# -*- coding: utf-8 -*-
require 'delegate'
require 'nokogiri'
require 'twob/thread/thread_document'

class SpecResponse < SimpleDelegator
  def initialize(response)
    super(response)
  end
  
  def write_body(buffer)
    super(buffer)
    @document = ThreadDocument.new(buffer.string)
  end
  
  def document
    @document
  end
end
