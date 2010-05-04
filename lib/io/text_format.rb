# -*- coding: utf-8 -*-
require 'io/encoder'

class TextFormat
  def initialize(encoding_name, line_delimiter)
    @encoder = Encoder.by_name(encoding_name)
    @line_delimiter = line_delimiter
  end
end