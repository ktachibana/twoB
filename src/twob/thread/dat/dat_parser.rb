# -*- coding: utf-8 -*-
require 'twob/thread/dat/dat_content'

module TwoB
  module Dat
    Part = Struct.new(:number_from, :offset_from, :number_to)
    TRIP_PATTERN = /\A([^<]*)(<\/b>\s*◆(\S+)\s*<b>)?\z/
    class DatParser
      def initialize()
        @thread_title = nil
        @res_list = []
        @index = {}
      end

      attr_accessor :thread_title, :res_list, :index

      def get_dat_content
        Dat::Content.new(@thread_title, @res_list)
      end

      def each_line_with_index(source, index = nil)
        source.open do |reader|
          reader.each_with_offset do |line, offset|
            next if line.empty?
            yield(line.split("<>"), offset)
          end
        end
      end

      def parse_delta(input_source, &block)
        input_source.open do |reader|
          reader.each_with_offset do |line, offset|
            next if line.empty?
            res = parse_line(line.split("<>"), &block)
            @index[res.number] = offset
          end
        end
        get_dat_content
      end

      def parse_cache(seekable_source, index, ranges)
        seekable_source.open do |reader|
          ranges.each do |range|
            next unless index.has_key?(range.begin)
            part = Part.new(range.begin, index[range.begin], range.end)

            self.on_start_part(part)
            parse_part(reader, part) do |values|
              self.parse_line(values)
            end
          end
        end
        self.get_dat_content
      end

      def parse_part(reader, part, &to_res_block)
        reader.seek(part.offset_from)
        parse(reader) do |values|
          res = to_res_block.call(values)
          break if res.number >= part.number_to
        end
      end

      def parse(reader)
        reader.each do |line|
          next if line.empty?
          yield(line.chomp.split("<>"))
        end
      end
    end
  end
end
