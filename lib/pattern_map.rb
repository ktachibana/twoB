# -*- coding: utf-8 -*-

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
