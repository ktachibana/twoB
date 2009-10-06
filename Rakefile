# -*- coding: utf-8 -*-
require 'tools/rake_util'
require 'spec/rake/spectask'

converter = "tools/erb2view.rb"
template = "tools/view_template.erb"

view_file_mapping = FileList["view/*.erb"].map do |erb_file|
  erb_file.pathmap("%{^view,src}X_view.rb")
end

task :default => :convert_all_view

task :convert_all_view => view_file_mapping.objects

view_file_mapping.each_mapping do |erb_file, view_rb_file|
  file view_rb_file => [erb_file, converter, template] do |t|
    require converter
    ERB2View::convert(erb_file, view_rb_file)
  end
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.libs = %w[src spec]
end
