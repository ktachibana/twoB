# -*- coding: utf-8 -*-

class PatternMap
  Pattern = Struct.new(:pattern, :match_to_value)
  def initialize
    @patterns = []
    if_any_matched { nil }
  end

  def map(pattern, &block)
    @patterns << Pattern.new(pattern, block)
  end

  def if_any_matched(&block)
    @if_any_matched = block
  end

  def get(key, *additional_args)
    result = @patterns.find_not_nil do |pattern|
      match = pattern.pattern.match(key)
      match ? pattern.match_to_value.call(match, *additional_args) : nil
    end
    @if_any_matched.call(key) if result.nil?
    result
  end
end
