#!/usr/bin/ruby -Isrc -Ispec
require 'rubygems'
require 'spec'
require 'pathname'

Pathname.glob("spec/**/*.rb").each do |file|
  require file.realpath
end
