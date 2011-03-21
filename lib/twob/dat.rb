# -*- coding: utf-8 -*-

module TwoB
  module Dat
    class Content
      def initialize(title, res_list)
        @title = title
        @res_list = res_list
      end

      attr_reader :title, :res_list

      Empty = self.new(nil, [])

      def +(other_content)
        title = self.title ? self.title : other_content.title
        res_list = self.res_list + other_content.res_list
        Content.new(title, res_list)
      end

      def has_title?
        @title && !@title.empty?
      end

      def each_res
        @res_list.each do |res|
          yield res
        end
      end

      def res_count
        @res_list.size
      end

      def empty?
        @res_list.empty?
      end

      def range
        empty? ? nil : first_res_number..last_res_number
      end

      def first_res_number
        empty? ? nil : @res_list.first.number
      end

      def last_res_number
        empty? ? nil : @res_list.last.number
      end
    end

    URL_PATTERN = /(http|ttp|tp)(:\/\/[0-9a-zA-Z_\!-\&\+\-\.\/\:\;\=\?\@\[-\`\{-\~]+)/
    ANCHOR_PATTERN = /(<a .*?>)?((&gt;)?&gt;(\d+)(\-\d+)?)(<\/a>)?/
    BREAK_LINE_PATTERN = %r|<br( /)?>|

    def parse_body(body_str)
      builder = ItemBuilder.new(body_str)
      builder.mark_pattern(ANCHOR_PATTERN) do |match|
        Anchor.new(match[2].gsub("&gt;", ">"))
      end
      builder.mark_pattern(BREAK_LINE_PATTERN) do
        BreakLine.new()
      end
      builder.mark_pattern(URL_PATTERN) do |match|
        Link.new(match[0], "http" + match[2])
      end
      builder.build do |str|
        Text.new(str)
      end
    end

    class Line
      def initialize(number, name, trip, mail, date, id, body)
        @number = number
        @name = name
        @trip = trip
        @mail = mail
        @date = date
        @id = id
        @body = body
      end

      attr_reader :number, :name, :trip, :mail, :date, :id, :body

      def has_trip?
        !trip.nil?
      end

      def age?()
        !mail.include?("sage")
      end
    end

    class ItemBuilder
      BodyItem = Struct.new(:body, :range)
      def initialize(body_str)
        @body_str = body_str
        @marked_items = []
      end

      def mark_pattern(pattern, &to_item)
        i = 0
        while match = pattern.match(@body_str[i..-1])
          range = (match.begin(0) + i) ... (match.end(0) + i)
          item = to_item.call(match)
          @marked_items << BodyItem.new(item, range)
          i = i + match.end(0)
        end
      end

      def build(&to_default_item)
        items = @marked_items.sort{|a, b| a.range.begin <=> b.range.begin }

        result = []
        i = 0
        items.each do |item|
          result << to_default_item.call(@body_str[i...item.range.begin]) unless item.range.begin == i
          result << item.body
          i = item.range.end
        end
        result << to_default_item.call(@body_str[i..-1]) unless i == @body_str.size
        result
      end
    end

    class Text
      def initialize(text)
        raise if text.nil?
        @text = text
      end

      def body_type
        :text
      end

      def to_s
        @text
      end

      def ==(other)
        to_s == other.to_s
      end
    end

    class Anchor
      PATTERN = /\>\>?(\d+)(\-(\d+))?/
      def initialize(anchor_str)
        @anchor_str = anchor_str
        match = PATTERN.match(@anchor_str)
        @first_id = match[1].to_i
        @last_id = match[3] ? match[3].to_i : nil
        @values = [@first_id, @last_id].compact
        raise anchor_str unless @values
      end

      attr_reader :first_id, :last_id

      def top_id
        @values.min
      end

      def bottom_id
        @values.max
      end

      def range
        top_id..bottom_id
      end

      def visible?(thread_range)

      end

      def body_type
        :anchor
      end

      def to_s
        @anchor_str
      end

      def ==(other)
        to_s == other.to_s
      end
    end

    class Link
      def initialize(text, url)
        @text = text
        @url = url
      end

      def body_type
        :link
      end

      def url
        @url
      end

      def link_type
        unless url.match(/^.+\.(jpeg|jpg|gif|png|bmp|jp2)$/i).nil?
          return :image
        else
          return nil
        end
      end

      def to_s
        @text
      end

      def ==(other)
        to_s == other.to_s && url == other.url
      end
    end

    class BreakLine
      def body_type
        :break_line
      end

      def ==(other)
        is_a?(other.class)
      end
    end

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
