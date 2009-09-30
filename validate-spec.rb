#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'opt'
require 'rubygems'
require 'spec/autorun'
require 'pathname'

Pathname.glob("spec/**/*.rb").each do |file|
  require file.realpath
end
