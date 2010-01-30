#!/usr/bin/ruby -Isrc
require 'twob/thread/index'
require 'pp'

file = ARGV.shift
pp Marshal.load(File.read(file))

