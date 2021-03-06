# -*- coding: utf-8 -*-
$VERBOSE = nil
require 'rubygems'
require 'rspec/core/rake_task'

converter = "tool/erb2view.rb"

module Rake
  # 既存のFileListクラスにmappingメソッドを追加
  class FileList
    def mapping(&convert_block)
      FileMapping.new(self) do |source|
        convert_block[source]
      end
    end
  end

  class FileMapping < Hash
    def initialize(sources, &to_object_block)
      sources.each do |source|
        self[source] = to_object_block[source]
      end
    end

    alias each_mapping each_pair
    alias sources keys
    alias objects values
  end
end

view_file_mapping = FileList["view/erb/**/*.erb"].mapping do |erb_file|
  erb_file.pathmap("%{^view/erb,view/lib}X_view.rb")
end

task :default => :spec

desc "view/*.erbを全てViewクラスのコードに変換する"
task :convert_all_view => view_file_mapping.objects

view_file_mapping.each_mapping do |erb_file, view_rb_file|
  file view_rb_file => [erb_file, converter] do |t|
    require converter
    ERB2View::convert(erb_file, view_rb_file)
  end
end

desc "rspecを実行する"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
  t.ruby_opts = %w(-r rubygems)
  t.pattern = "spec/unit/**/*_spec.rb"
  t.rspec_opts = %w(--format documentation --color)
end
task :spec => :convert_all_view

desc "機能テストを実行する"
RSpec::Core::RakeTask.new(:fspec) do |t|
  t.fail_on_error = false
  t.ruby_opts = %w(-r rubygems)
  t.pattern = "spec/function/**/*_spec.rb"
  t.rspec_opts = %w(--format documentation --color)
end
task :fspec => [:convert_all_view]

module Rake
  # 既存のFileListクラスにmappingメソッドを追加
  class FileList
    def mapping(&convert_block)
      FileMapping.new(self) do |source|
        convert_block[source]
      end
    end
  end

  class FileMapping < Hash
    def initialize(sources, &to_object_block)
      sources.each do |source|
        self[source] = to_object_block[source]
      end
    end

    alias each_mapping each_pair
    alias sources keys
    alias objects values
  end
end
