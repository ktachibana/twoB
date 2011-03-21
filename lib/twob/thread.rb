# -*- coding: utf-8 -*-

require 'framework/handler'
require 'twob/dat'
require 'twob/picker'
require 'twob/thread_view'
require 'io'
require 'encoder'
require 'util'
require 'forwardable'

module TwoB
  class Thread
    include Enumerable
    def initialize(thread, caches, delta, picker, metadata)
      @thread = thread
      @caches = caches
      @delta = delta
      @picker = picker
      @metadata = metadata
    end

    attr_reader :thread, :caches, :delta, :metadata

    def title
      @caches.each{|cache| return cache.title if cache.has_title? }
      @delta.title
    end

    def original_url
      @thread.original_url
    end

    def dat_url
      @thread.dat_url
    end

    def [](number)
      find do |res|
        res.number == number
      end
    end

    class Templates
      def initialize
        @templates = {}
      end

      def match(key, &template)
        @templates[key] = template
      end

      def do_apply(key, *object)
        @templates[key].call(*object) if @templates.include?(key)
      end
    end

    class Gap
      def initialize(prev_range, next_range)
        @prev_range, @next_range = prev_range, next_range
      end

      def shrink_last(size)
        shurinked = @next_range.first - size
        (shurinked > @prev_range.last+1) ? shurinked : @prev_range.first
      end
    end

    def each_item
      templates = Templates.new
      yield templates

      @caches.each_with_index do |cache, index|
        cache.each_res do |res|
          templates.do_apply(:res, Res.new(res, unread?(res)))
        end
        if index < (@caches.length - 1)
          next_cache = @caches[index+1]
          templates.do_apply(:gap, Gap.new(cache.range, next_cache.range))
        end
      end
      return if @delta.empty?
      templates.do_apply(:border)
      @delta.each_res do |res|
        templates.do_apply(:res, Res.new(res, true))
      end
    end

    def each_res
      @caches.each do |cache|
        cache.each_res do |res|
          yield Res.new(res, unread?(res))
        end
      end
      @delta.each_res do |res|
        yield Res.new(res, true)
      end
    end
    alias :each :each_res

    def visible_all?(anchor)
      ranges.include_range?(anchor.range)
    end

    def ranges
      @picker.to_ranges(@metadata.last_res_number, @delta.last_res_number, bookmark_number)
    end
    private :ranges

    def res_count
      @caches.sum{|cache| cache.res_count } + delta.res_count
    end

    def last_res_number
      @delta.empty? ? @caches.last.last_res_number : @delta.last_res_number
    end

    def has_new?
      !@delta.empty? || bookmarking?
    end

    def bookmarking?
      !@metadata.bookmark_number.nil?
    end

    def bookmark_number
      @metadata.bookmark_number
    end

    def unread?(res)
      bookmarking? ? res.number > bookmark_number : false;
    end

    def first_new_number
      bookmarking? ? bookmark_number + 1 : @cache.res_count + 1
    end

    def read_number
      bookmarking? ? bookmark_number : @metadata.last_res_number
    end
  end

  #= レスの>>1-50とかの並び。>>1とか一個しかなくても並び
  class ResSequence
    def initialize(res_seq, is_new)
      @res_seq = res_seq
      @is_new = is_new
    end

    attr_reader :res_seq

    # このレス群は新着？
    def new?
      @is_new
    end
  end

  class Res
    extend Forwardable
    def initialize(dat_res, is_new)
      @dat_res = dat_res
      @is_new = is_new
    end

    def_delegators :@dat_res, :number, :name, :has_trip?, :trip, :mail, :age?, :date, :id, :body

    def new?() @is_new end
  end

  module ThreadHandler
    include TwoB::Handler
    def execute(request, value)
      case value
      when /^delete_cache$/
        delete_cache(request.get_param("reload"))
      when /^delete_bookmark$/
        delete_bookmark()
      when /^res_anchor$/
        res_anchor(Pickers.get(request.get_param("picker")))
      else
        read(Pickers.get(value))
      end
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
      delta_bytes = system.get_bytes(request)
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

  class ThreadBuilder
    def initialize(factory, thread_key, picker)
      @factory, @thread_key, @picker = factory, thread_key, picker

      @metadata = @factory.load_metadata
      @caches = []
      @delta_builder = @factory.dat_builder
      @cache = TwoB::Cache::Empty
      @delta = TwoB::Delta.new(TwoB::Dat::Content::Empty, 0, [], {})
      @update_time = Time.now
    end

    def cached_number
      @metadata.last_res_number
    end

    def bookmark_number
      @metadata.bookmark_number
    end

    def load_cache(*ranges)
      begin
        cache_source = @factory.cache_source
        cache_source.open do |reader|
          Ranges.new(*ranges).limit_range(1..cached_number).each do |range|
            @caches << load_cache_sequence(reader, range)
          end
        end
      rescue Errno::ENOENT
        # do nothing
      end
    end

    def load_cache_sequence(reader, range)
      cache_builder = @factory.dat_builder
      cache_builder.start(range.first)
      reader.seek(@metadata[range.first])
      reader.each do |line|
        next if line.empty?
        cache_builder.build(line.chomp.split("<>")) do |res|
          return cache_builder.result unless range.include?(res.number)
          true
        end
      end
      cache_builder.result
    end
    private :load_cache_sequence

    def load_delta(&filter)
      delta_source = @factory.delta_source_from(@metadata)
      delta_index = {}
      delta_source.open do |reader|
        @delta_builder.start(@metadata.last_res_number + 1)
        reader.each_with_offset do |line, offset|
          next if line.empty?
          res = @delta_builder.build(line.chomp.split("<>"), &filter)
          delta_index[res.number] = offset
        end
      end
      @delta = TwoB::Delta.new(@delta_builder.result, @metadata.last_res_number, delta_source.bytes, delta_index)
      @delta
    end

    def update
      @factory.update(@delta, @metadata, @update_time)
    end

    def result
      TwoB::Thread.new(@thread_key, @caches, @delta, @picker, @metadata)
    end
  end

  class ResService
    include TwoB::Handler
    def initialize(thread, number)
      @thread = thread
      @number = number
    end

    attr_reader :thread, :number

    def system
      @thread.system
    end

    def execute(request, value)
      case value
      when /^bookmark$/
        bookmark()
      end
    end

    def bookmark()
      @thread.update_bookmark_number(number)
      RedirectResponse.new("../subscribe5")
    end
  end

  class Metadata
    def initialize(last_res_number, cache_file_size, bookmark_number)
      @last_res_number = last_res_number
      @cache_file_size = cache_file_size
      @bookmark_number = bookmark_number
      @index = {}
    end

    attr_accessor :last_res_number, :cache_file_size, :bookmark_number, :index

    def update(delta)
      result = self.dup
      result.update!(delta)
      result
    end

    def update!(delta)
      append(delta.index)
      @last_res_number = delta.last_res_number
      @cache_file_size += delta.bytes_size
    end

    def append(delta_index)
      delta_index.each do |number, source_offset|
        @index[number] = @cache_file_size + source_offset
      end
    end

    def has?(number)
      @index.has_key?(number)
    end

    def [](res_number)
      @index[res_number]
    end

    def []=(res_number, offset)
      @index[res_number] = offset
    end
  end

  class Delta
    def initialize(dat_content, base_res_number, bytes, index)
      @dat_content = dat_content
      @base_res_number = base_res_number
      @bytes = bytes
      @index = index
    end

    attr_reader :dat_content, :base_res_number, :bytes, :index

    def title
      @dat_content.title
    end

    def each_res
      @dat_content.each_res do |res|
        yield res
      end
    end

    def bytes_size
      @bytes.length
    end

    def res_count
      @dat_content.res_count
    end

    def empty?
      @dat_content.empty?
    end

    def last_res_number
      @dat_content.empty? ? @base_res_number : @dat_content.last_res_number
    end

    def range
      @dat_content.range
    end
  end

  class Cache
    def initialize(dat_content)
      @dat_content = dat_content
    end

    Empty = self.new(TwoB::Dat::Content::Empty)

    attr_reader :dat_content

    def new_number
      @dat_content.empty? ? 1 : @dat_content.last_res_number + 1
    end

    def title
      @dat_content.title
    end

    def has_title?
      @dat_content.has_title?
    end

    def each_res
      @dat_content.each_res do |res|
        yield res
      end
    end

    def res_count
      @dat_content.res_count
    end

    def last_number
      @dat_content.last_res_number
    end

    def range
      @dat_content.range
    end
  end
end
