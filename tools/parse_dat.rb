#!/usr/bin/ruby -Isrc
# encoding: utf8
$KCODE = "utf8"

require 'pathname'
require 'source'
require 'bbs2ch/thread/dat_parser'
require 'dat_view'

dat_file_string = ARGV.shift
raise("missing dat-file parameter.") unless dat_file_string
dat_file = Pathname.new(dat_file_string)

dat = BBS2ch::DatParser.new.parse(TextFile.new(dat_file, "shift_jis"))

DatView.new(dat).write(STDOUT)
