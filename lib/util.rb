# -*- coding: utf-8 -*-

module Enumerable
  #= 合計。
  # sum_size = items.sum{|item| item.size }
  def sum
    inject(0){|result, item| result + yield(b) }
  end

  def find_not_nil
    each do |item|
      value = yield(item)
      return value unless value.nil?
    end
    return nil
  end
end

class Range
  def include_range?(other)
    self.include?(other.begin) && self.include?(other.end)
  end

  def adjacent?(other)
    Range.new(self.first - 1, self.last + 1, self.exclude_end?).include?(other)
  end

  def adjacent_range?(other)
    self.adjacent?(other.first) || other.adjacent?(self.first)
  end

  def last_include_end
    last - (exclude_end? ? 1 : 0)
  end

  def compose(other)
    ranges = [self, other]
    new_first = ranges.min do |a, b|
      a.first <=> b.first
    end
    new_last = ranges.max do |a, b|
      if a.last == b.last
        (a.exclude_end? ? 0 : 1) <=> (b.exclude_end? ? 0 : 1)
      else
        a.last <=> b.last
      end
    end
    Range.new(new_first.first, new_last.last, new_last.exclude_end?)
  end
end

class Ranges < Array
  def initialize(*ranges)
    super(ranges)
  end

  def self.union(*ranges)
    new(*ranges).union
  end

  # 機能不十分：以下のコードはパスしない。
  # ranges = Ranges.union(1..3, 7..10, 4..6)
  # ranges.should == [1..10]
  # ranges = Ranges.union(7..10, 1..3, 4..6)
  # ranges.should == [1..10]
  def union
    results = Ranges.new
    self.each do |range|
      adjacent_index = results.index{|r| r.adjacent_range?(range) }
      if adjacent_index
        results[adjacent_index] = results[adjacent_index].compose(range)
      else
        results << range.dup
      end
    end
    results
  end

  def include_range?(range)
    self.any? do |r|
      r.include_range?(range)
    end
  end

  def limit_range(limit_range)
    results = collect { |range|
      [range.first, limit_range.first].max .. [range.last, limit_range.last].min
    }.select { |range|
      range.first <= range.last
    }
    self.class.new(*results)
  end

  def limit(max)
    results = self.collect { |range|
      range.first .. [range.last, max].min
    }.select { |range|
      range.first <= range.last
    }
    self.class.new(*results)
  end
end

class Class
  def equality(*symbols)
    define_method(:==) do |other|
      return false unless other.instance_of?(self.class)

      symbols.all? do |symbol|
        self.instance_variable_get(symbol) == other.instance_variable_get(symbol)
      end
    end
  end
end

class PatternMap
  Pattern = Struct.new(:pattern, :match_to_value)
  def initialize
    @patterns = []
    unmatched { nil }
  end

  def map(pattern, &block)
    @patterns << Pattern.new(pattern, block)
  end

  def unmatched(&block)
    @unmatched = block
  end

  def get(key, *additional_args)
    result = @patterns.find_not_nil do |pattern|
      match = pattern.pattern.match(key)
      match ? pattern.match_to_value.call(match, *additional_args) : nil
    end
    @unmatched.call(key) if result.nil?
    result
  end
end
