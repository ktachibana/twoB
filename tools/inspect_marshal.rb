#!/usr/bin/ruby -Isrc
require 'jbbs/thread/index'

file = ARGV.shift
p Marshal.load(File.read(file))

