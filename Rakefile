# -*- coding: utf-8 -*-
require 'tools/rake_util'

CONVERTER = "tools/erb2view.rb"
TEMPLATE = "tools/view_template.erb"

VIEW_FILES = FileList["view/*.erb"].mapping do |erb_file|
  erb_file.pathmap("%{^view,src}X_view.rb")
end

task :default => :convert_all_view

task :convert_all_view => VIEW_FILES.objects

VIEW_FILES.each do |erb_file, view_file|
  file view_file => [erb_file, CONVERTER, TEMPLATE] do |t|
    require CONVERTER
    ERB2View::convert_by_file(erb_file, view_file)
  end
end
