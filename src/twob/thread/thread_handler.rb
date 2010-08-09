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
        delete_cache(request.get_param("reload"))
      when /^delete_bookmark$/
        delete_bookmark()
      when /^res_anchor$/
        res_anchor(Pickers.get(request.get_param("range")))
      else
        read(Pickers.get(value))
      end
    end

    def action_map()
      map(:delete_cache) { |request| [request.get("reload")] }
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

    def read(requested_picker)
      builder = TwoB::ThreadBuilder.new(self, self, requested_picker)
      requested_picker.build_thread(builder)

      TwoB::ThreadView.new(builder.result)
    end

    def cache_file
      data_directory + "#{number}.dat"
    end

    def metadata_file
      data_directory + "#{number}.yaml"
    end

    def load_delta(metadata)
      dat_parser = get_delta_parser(metadata.last_res_number + 1)
      bytes_source = delta_source_from(metadata)
      delta_content = dat_parser.parse_delta(bytes_source)
      TwoB::Delta.new(delta_content, metadata.last_res_number, bytes_source.bytes, dat_parser.index)
    end

    def delta_source_from(metadata)
      delta_source(delta_request(metadata))
    end

    def delta_source(request)
      delta_bytes = system.get_delta_input(request).read()
      BytesSource.new(delta_bytes, Encoder.by_name(dat_encoding_name), dat_line_delimiter)
    end

    def cache_source
      TextFile.new(cache_file, dat_encoding_name)
    end

    def delete_cache(reload)
      cache_manager.delete()
      metadata_manager.delete()
      read_counter.delete(number)
      RedirectResponse.new(reload ? "./#{reload}" : "../")
    end

    def delete_bookmark()
      update_bookmark_number(nil)
      RedirectResponse.new("./subscribe5")
    end

    def update_bookmark_number(bookmark_number)
      metadata_manager.update do |metadata|
        metadata.bookmark_number = bookmark_number
      end
    end

    def res_anchor(requested_picker)
      builder = TwoB::ThreadBuilder.new(self, self, requested_picker)
      requested_picker.build_anchor(builder)
      TwoB::ThreadView.new(builder.result)
    end
  end
end
