module Input
  def read
    result = ""
    each_read do |data|
      result << data
    end
    result
  end
end
