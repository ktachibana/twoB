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
        delete_cache(request.has_param?("reload"))
      when /^delete_bookmark$/
        delete_bookmark()
      when /^res_anchor$/
        res_anchor(Pickers.get(request.get_param("range")))
      else
        read(Pickers.get(value))
      end
    end
    
    def action_map()
      map(:delete_cache) { |request| [request.has_param?("reload")] }
      map(:delete_bookmark)
      map(:res_anchor) { |request| [Pickers.get(request.get_param("range"))] }
      map() { |request, value| [Pickers.get(value)] }
    end
    
    def /(value)
      TwoB::ResService.new(self, value.to_i)
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
    
    def load_delta(index)
      delta_bytes = system.get_delta_input(delta_request(index)).read()
      dat_parser = get_delta_parser(index.last_res_number + 1)
      delta_content = dat_parser.parse_delta(delta_source(delta_bytes))
      TwoB::Delta.new(delta_content, index.last_res_number, delta_bytes, dat_parser.index)
    end

    def delta_source(delta_bytes)
      BytesSource.new(delta_bytes, Encoder.by_name(dat_encoding_name), dat_line_delimiter)
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
      RedirectResponse.new("./subscribe5")
    end
    
    def update_bookmark_number(bookmark_number)
      index_manager.update do |index|
        index.bookmark_number = bookmark_number
      end
    end

    def res_anchor(picker)
      index = index_manager.load
      ranges = picker.concretize(index.last_res_number, index.last_res_number).ranges
      cache = cache_manager.load(ranges, index)
      anchor_res = []
      cache.each_res do |res|
        anchor_res << TwoB::Res.as_cache(res)
      end
      TwoB::ResAnchorView.new(anchor_res)
    end
  end
end
