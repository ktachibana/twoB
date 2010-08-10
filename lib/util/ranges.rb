require 'util/range'

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