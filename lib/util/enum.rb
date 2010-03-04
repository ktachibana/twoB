module Enumerable
  def find_not_nil
    each do |item|
      value = yield(item)
      return value unless value.nil?
    end
    return nil
  end
end
