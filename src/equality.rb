class Class
  def equality(*symbols)
    define_method(:==) do |other|
      return false unless other.instance_of?(self.class)
      
      symbols.all? do |symbol|
        self.instance_variable_get(symbol) == other.instance_variable_get(symbol)
      end
    end
  end
end
