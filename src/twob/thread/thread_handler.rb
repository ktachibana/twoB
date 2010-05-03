# -*- coding: utf-8 -*-
require 'twob/handler'
require 'yaml_marshaler'
require 'io/source'

module TwoB
  module ThreadHandler
    include TwoB::Handler
    
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
      system.configuration.data_directory + board.data_directory_path
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
    
    def delta_source(delta_bytes)
      BytesSource.new(delta_bytes, Encoder.by_name(dat_encoding_name), dat_line_delimiter)
    end

    def load_delta(index)
      delta_bytes = get_new_input(delta_request(index)).read()
      dat_parser = get_delta_parser(index.last_res_number + 1)
      delta_content = dat_parser.parse_delta(delta_source(delta_bytes))
      TwoB::Delta.new(delta_content, delta_bytes, dat_parser.index)
    end

    def get_new_input(request)
      HTTPGetInput.new(request)
    end

    def cache_source
      TextFile.new(cache_file, dat_encoding_name)
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

    def res_anchor(picker)
      index = index_manager.load
      ranges = picker.concretize(index.last_res_number).ranges
      cache = cache_manager.load(ranges, index)
      anchor_res = []
      cache.each_res do |res|
        anchor_res << TwoB::Res.as_cache(res)
      end
      TwoB::ResAnchorView.new(anchor_res)
    end
  end
end
