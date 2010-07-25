# -*- coding: utf-8 -*-
require 'equality'
require 'uri'

module TwoB
  class Request
    def initialize(path_info, param = {}, env = {})
      @path_info = path_info
      @param = param
      @path_info_uri = URI.parse(path_info ? path_info : "")
      @script_name = env["SCRIPT_NAME"]
      @request_uri = env["REQUEST_URI"]
    end

    def path_info
      @path_info_uri.path
    end

    attr_reader :param, :script_name, :request_uri
    equality :@path_info, :@param, :@script_name, :@request_uri

    def request_script
      @request_uri.chomp(@path_info)
    end

    def fragment
      @path_info_uri.fragment
    end

    def has_param?(key_name)
      @param.has_key?(key_name)
    end

    def get_param(key_name)
      @param[key_name][0]
    end
  end
end
