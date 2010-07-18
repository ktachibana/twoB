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
