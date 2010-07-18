# -*- coding: utf-8 -*-
require 'io/input'
require 'io/source'

class StringInput
  include Input
  def initialize(*bytes_list)
    @bytes_list = bytes_list
  end

  def self.empty
    new()
  end

  def each_read
    @bytes_list.each do |bytes|
      yield bytes
    end
  end
end

class StringSource < BytesSource
  include Enumerable
  def initialize(str)
    super(str, Encoder::Literal, $/)
  end

  def self.empty()
    new("")
  end
end
