# -*- coding: utf-8 -*-
require 'rake'

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
    
    alias :each_mapping :each_pair
    alias :sources :keys
    alias :objects :values
  end
end
