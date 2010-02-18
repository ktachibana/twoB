require 'twob/thread/dat/dat_content'

module TwoB
  module Dat
    Part = Struct.new(:number_from, :offset_from, :number_to)
  
    class DatParser
      TRIP_PATTERN = /\A([^<]*)(<\/b>\s*◆(\S+)\s*<b>)?\z/
    
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
      
      def parse_delta(input_source)
        input_source.open do |reader|
          reader.each_with_offset do |line, offset|
            next if line.empty?
            parse_line(line.split("<>"))
            @index[last_number] = offset
          end
        end
        get_dat_content
      end
      
      def parse_with_index(seekable_source, index, ranges)
        parts = ranges.collect do |range|
          Part.new(range.begin, index[range.begin], range.end) if index.has?(range.begin)
        end
        parts.compact!
        parse_parts(seekable_source, parts)
      end
  
      def parse_parts(seekable_source, parts)
        seekable_source.open do |reader|
          parts.each do |part|
            on_start_part(part)
            reader.seek(part.offset_from)
            reader.each do |line|
              parse_line(line.chomp.split("<>"))
              break if last_number >= part.number_to
            end
          end
        end
        get_dat_content
      end
      
      def last_number
        @res_list.last.number
      end
    end
  end
end
