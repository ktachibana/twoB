# -*- coding: utf-8 -*-
$VERBOSE = nil
require 'rubygems'
require 'tools/rake_util'
require 'spec/rake/spectask'
$LOAD_PATH << "lib"
$LOAD_PATH << "spec/unit"

converter = "bin/erb2view.rb"
template = "bin/view_template.erb"

view_file_mapping = FileList["view/erb/**/*.erb"].mapping do |erb_file|
  erb_file.pathmap("%{^view/erb,view/src}X_view.rb")
end

task :default => :spec

desc "view/*.erbを全てViewクラスのコードに変換する"
task :convert_all_view => view_file_mapping.objects

view_file_mapping.each_mapping do |erb_file, view_rb_file|
  file view_rb_file => [erb_file, converter, template] do |t|
    require converter
    ERB2View::convert(erb_file, view_rb_file)
  end
end

desc "rspecを実行する"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.fail_on_error = false
  t.ruby_opts = %w(-r rubygems)
  t.spec_files = FileList["spec/unit/**/*_spec.rb"]
  t.spec_opts = %w(--format html:local/spec/unit.html --format nested --color)
  t.libs = %w[lib view/src spec/unit]
  t.rcov = ENV.include? "rcov"
  t.rcov_dir = "local/coverage"
  t.rcov_opts << %w(--exclude ^spec --include-file ^lib)
end
task :spec => :convert_all_view

desc "機能テストを実行する"
Spec::Rake::SpecTask.new(:fspec) do |t|
  t.fail_on_error = false
  t.ruby_opts = %w(-r rubygems)
  t.spec_files = FileList["spec/function/**/*_spec.rb"]
  t.spec_opts = %w(--format html:local/spec/function.html --format nested --color)
  t.libs = %w[lib view/src spec/unit spec/function]
  t.rcov = ENV.include? "rcov"
  t.rcov_dir = "local/coverage"
  t.rcov_opts << %w(--exclude ^spec --include-file ^lib)
end
task :fspec => [:convert_all_view, :spec]
