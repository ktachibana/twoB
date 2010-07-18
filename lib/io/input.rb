module Input
  # def each_read; end;
  def read
    result = ""
    each_read do |data|
      result << data
    end
    result
  end
end
