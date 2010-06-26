require 'util/range'

class Ranges < Array
  def initialize(*ranges)
    results = []
    ranges.each do |range|
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
    super(results)
  end

  def include_range?(range)
    self.any? do |r|
      r.include_range?(range)
    end
  end

  def limitation(max)
    results = self.collect { |range|
      range.first .. [range.last, max].min
    }.select { |range|
      range.first <= range.last
    }
    self.class.new(*results)
  end
end