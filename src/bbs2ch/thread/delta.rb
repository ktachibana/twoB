# -*- coding: utf-8 -*-

module BBS2ch
  class Delta
    def initialize(data, dat_content)
      @data = data
      @dat_content = dat_content
    end
    
    attr_reader :data, :dat_content
  end
end