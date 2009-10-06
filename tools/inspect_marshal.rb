#!/usr/bin/ruby -Isrc
require 'jbbs/thread/index'
require 'pp'

file = ARGV.shift
pp Marshal.load(File.read(file))

