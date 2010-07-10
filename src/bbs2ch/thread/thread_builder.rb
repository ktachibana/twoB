# -*- coding: utf-8 -*-
require 'twob/thread/cache'
require 'twob/thread/delta'

module BBS2ch
  class ThreadBuilder
    def initialize(factory, thread_key, picker)
      @factory, @thread_key, @picker = factory, thread_key, picker
      @index = factory.load_index
      @cache_builder = factory.dat_builder
      @cache_source = factory.cache_source
      @delta_builder = factory.dat_builder
      @delta_source = factory.delta_source_from(@index)
      @delta_index = {}
      @cache = TwoB::Cache::Empty
      @delta = TwoB::Delta.new(TwoB::Dat::Content::Empty, 0, [], {})
      @update_time = Time.now
    end

    def cached_number
      @index.last_res_number
    end

    def bookmark_number
      @index.bookmark_number
    end

    def load_cache(*ranges)
      begin
        @cache_source.open do |reader|
          ranges.each do |range|
            load_cache_from(reader, range)
          end
        end
      rescue Errno::ENOENT
        # do nothing
      end
      @cache = TwoB::Cache.new(@cache_builder.result)
    end

    def load_cache_from(reader, range)
      @cache_builder.start(range.first)
      reader.seek(@index[range.first])
      reader.each do |line|
        next if line.empty?
        @cache_builder.build(line.chomp.split("<>")) do |res|
          return unless range.include?(res.number)
          true
        end
      end
    end
    private :load_cache_from

    def load_delta(&filter)
      @delta_source.open do |reader|
        @delta_builder.start(@index.last_res_number + 1)
        reader.each_with_offset do |line, offset|
          next if line.empty?
          res = @delta_builder.build(line.chomp.split("<>"), &filter)
          @delta_index[res.number] = offset
        end
      end
      @delta = TwoB::Delta.new(@delta_builder.result, @index.last_res_number, @delta_source.bytes, @delta_index)
    end

    def update
      @factory.update(@delta, @index, @update_time)
    end

    def result
      TwoB::Thread.new(@thread_key, @cache, @delta, @picker, @index)
    end
  end
end
