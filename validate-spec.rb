#!/usr/bin/ruby -Ku -Isrc -Ispec
# -*- coding: utf-8 -*-
require 'rubygems'
require 'spec/autorun'
require 'pathname'

Pathname.glob("spec/**/*.rb").each do |file|
  require file.realpath
end
