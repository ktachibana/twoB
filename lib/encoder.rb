require 'iconv'

class Encoder
  class Literal
    def name
      "Literal"
    end

    def self.encode(string_bytes)
      string_bytes
    end
  end

  def initialize(name, converter, alt_char = "?")
    @name = name
    @converter = converter
    @alt_char = alt_char
  end

  def self.by_name(encoding_name, alt_char = "?")
    new(encoding_name, Iconv.new("UTF-8", encoding_name), alt_char)
  end

  def name
    @name
  end

  def encode(bytes)
    begin
      return @converter.iconv(bytes)
    rescue Iconv::IllegalSequence => e
      if rest = e.failed[1..-1]
        return e.success + @alt_char + encode(rest)
      else
        return e.success
      end
    end
  end
end
