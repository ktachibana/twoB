# -*- coding: utf-8 -*-
require 'pathname'
require 'twob'
require 'spec_response'

class SpecSystem < TwoB::System
  SpecConfiguration = TwoB::Configuration.new(Pathname.new("local/spec_cache"))
  def initialize(request = nil)
    super(SpecConfiguration)
    @request = request
    @response = :yet_to_be_processed
    @buffer = StringIO.new

    @dat_delta_source = StringIO.new
  end

  attr_accessor :request, :response

  def output(response)
    @response = SpecResponse.new(response)
    @response.write_body(@buffer)
  end

  def handle_error(e)
    $stderr.puts(@buffer.string)
    $stderr.puts
    raise e
  end

  def self.clear_cache_dir
    SpecConfiguration.data_directory.rmtree rescue nil
  end

  def get_delta_input(request)
    raise "delta_inputのスタブが設定されていません"
  end

  def get_subject_source(request, encoder, line_delimiter)
    raise "subject_sourceのスタブが設定されていません"
  end
end

