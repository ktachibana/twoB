require 'util/range'

class Ranges < Array
  def initialize(*ranges)
    super(ranges)
  end
  
  def self.union(*ranges)
    new(*ranges).union
  end
  
  def union
    results = Ranges.new
    self.each do |range|
      adjacent_index = nil
      results.each_with_index do |result, index|
        if range.adjacent_range?(result)
          adjacent_index = index
          break
        end
      end
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

  def limit(max)
    results = self.collect { |range|
      range.first .. [range.last, max].min
    }.select { |range|
      range.first <= range.last
    }
    self.class.new(*results)
  end
end