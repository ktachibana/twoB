# -*- coding: utf-8 -*-

module TwoB
  class DatLine
    def initialize(values)
      @values =  values
    end
    
    def self.parse(dat_line_text)
      new(dat_line_text.split("<>"))
    end
  end
end