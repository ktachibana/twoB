# -*- coding: utf-8 -*-
require 'twob/thread/metadata'

module BBS2ch
  class Metadata < TwoB::Metadata
    def initialize(last_res_number, cache_file_size, last_modified)
      super(last_res_number, cache_file_size)
      @last_modified = last_modified
    end

    def self.empty()
      new(0, 0, nil)
    end

    attr_accessor :last_modified

    def empty?
      @last_modified.nil?
    end

    def dat_header
      header = {}
      return header if empty?
      header["Range"] = "bytes=#{@cache_file_size}-" unless @cache_file_size.zero?
      header["If-Modified-Since"] = last_modified.httpdate if last_modified
      header
    end
  end
end
