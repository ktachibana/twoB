#!/usr/bin/ruby -Isrc -Ilib
# -*- coding: utf-8 -*-
require 'twob'
require 'pathname'
require 'marshaler'
require 'yaml'

file = ARGV.shift

marshaler = TwoB::Marshaler.new(file, nil)

obj = marshaler.load()
raise unless obj

outfile = file.sub(/\.marshal\z/, ".yaml")
File.open(outfile, "w"){|f|
  YAML.dump(obj, f)
}
