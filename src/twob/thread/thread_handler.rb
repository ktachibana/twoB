# -*- coding: utf-8 -*-
require 'twob/thread'
require 'yaml_marshaler'
require 'io/source'

module TwoB
  # includeするクラスは以下のメソッドを提供すること
  # * [number => Integer] スレッド番号
  # * [original_url => String] スレッドをブラウザで通常表示するためのURL
  # * [data_directory_path] Pathname データ保存用ディレクトリ(相対パス)
  # * [get_dat_url(from => Integer) => String] datファイルのレス番号from以降の部分を取得するURLを返す
  # * [dat_encoding => String] datファイルのエンコーディング(iconv用)
  # * [get_dat_parser(from => Integer) => TwoB::DatParser] TwoB::DatParserの派生クラスのオブジェクトを返す
  # * [system] configuration,output(view)メソッドを提供するオブジェクト
  # * [read_counter => TwoB::ReadCounter] 
  module ThreadHandler
    def execute(request, value)
      case value
      when /^delete_cache$/
        delete_cache(request.param.has_key?("reload"))
      when /^delete_bookmark$/
        delete_bookmark()
      when /^res_anchor$/
        res_anchor(TwoB::Pickers.get(request.param["range"][0]))
      else
        label_index = value.index("#")
        picker_string = label_index ? value[0...label_index] : value
        read(TwoB::Pickers.get(picker_string))
      end
    end
    
    def data_directory
      system.configuration.data_directory + data_directory_path
    end
    
    def cache_file
      data_directory + "#{number}.dat"
    end
    
    def index_file
      data_directory + "#{number}.index.yaml"
    end
    
    def option_file
      data_directory + "#{number}.option.yaml"
    end
    
    def get_new(from)
      get_dat_parser(from).parse(get_dat_source(from))
    end

    def delete_cache(reload)
      cache_manager.delete()
      index_manager.delete()
      read_counter.delete(number)
      RedirectResponse.new(reload ? "./" : "../")
    end
    
    def delete_bookmark()
      update_bookmark_number(nil)
      RedirectResponse.new("./l50")
    end
    
    def option_manager
      TwoB::YAMLMarshaler.new(option_file, TwoB::ThreadOption.empty)
    end

    def update_bookmark_number(bookmark_number)
      option_manager.update do |option|
        option.bookmark_number = bookmark_number
      end
    end
  end
end
