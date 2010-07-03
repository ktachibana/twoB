#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'twob'

class Factory
  def initialize(filename)
    @file = BytesSource.new(File.read(filename), Encoder.by_name("windows-31j"), "\n")
  end
  def dat_builder
    BBS2ch::DatBuilder.new
  end
  
  def delta_source_from(metadata)
    @file
  end
end

index = BBS2ch::Index.empty
builder = BBS2ch::ThreadBuilder.new(Factory.new(ARGV.shift), nil, nil, index)
builder.load_delta
delta = builder.instance_variable_get(:@delta)
index.update(delta)
YAML::dump(index, $stdout)
