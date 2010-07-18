# -*- coding: utf-8 -*-
require 'delegate'
require 'nokogiri'
require 'twob/thread/thread_document'

class SpecResponse < SimpleDelegator
  def initialize(response)
    super(response)
    @buffer = nil
  end

  def write_body(buffer)
    super(buffer)
    @buffer = buffer
  end

  def string
    @buffer.string
  end

  def as_document
    @document = Nokogiri::HTML(string)
  end

  def as_thread
    ThreadDocument.new(string)
  end
end
