# -*- coding: utf-8 -*-

class PatternMap
  Pattern = Struct.new(:pattern, :create)
  def initialize
    @patterns = []
  end

  def map(pattern, &block)
    @patterns << Pattern.new(pattern, block)
  end

  def get(key, *additional_args)
    result = @patterns.find_not_nil do |pattern|
      match = pattern.pattern.match(key)
      match.nil? ? nil : pattern.create.call(match, *additional_args)
    end
    raise "matched pattern not found. key: #{key}" if result.nil?
    result
  end
end
