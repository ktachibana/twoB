# -*- coding: utf-8 -*-
require 'twob/application'
require 'pathname'
require 'twob'
require 'spec_response'

module TwoB
  module Spec
    DATA_DIRECTORY = "local/spec/data"
    def data_directory
      DATA_DIRECTORY
    end

    def data_path
      Pathname.new(DATA_DIRECTORY)
    end

    def root
      TwoB::RootHandler.new(configuration, SpecBackend.new)
    end

    def configuration
      TwoB::Configuration.new(data_path)
    end

    def clear_cache_dir
      data_path.rmtree rescue nil
    end

    class SpecFrontend
      include TwoB::Spec
      def initialize
        @request = :yet_to_be_access
        @response = :yet_to_be_processed
        @system = :yet_to_be_processed
        @buffer = StringIO.new
        @backend = SpecBackend.new
      end

      attr_reader :request, :response, :system

      def output(response)
        @response = SpecResponse.new(response)
        @response.write_body(@buffer)
      end

      def handle_error(e)
        raise e
      end

      def access(request, backend)
        @request = request
        TwoB::Application.new(self, @request, backend).main
      end
    end

    class SpecBackend
      def get_bytes(request)
        raise "get_bytesのスタブが設定されていません"
      end

      def get_subject_source(request, encoder, line_delimiter)
        raise "subject_sourceのスタブが設定されていません"
      end
    end

    class SpecRequest < TwoB::Request
      def initialize(path_info, param = {})
        env = {"SCRIPT_NAME" => script_name, "REQUEST_URI" => script_uri + path_info}
        super(path_info, param, env)
        @param = param
      end

      def script_name
        "/twoB/action"
      end

      def script_uri
        "http://192.168.0.6#{script_name}"
      end

      def request_uri
        script_uri + @path_info
      end
    end

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
        Nokogiri::HTML(string)
      end

      def as_thread
        ThreadDocument.new(string)
      end
    end
  end
end
