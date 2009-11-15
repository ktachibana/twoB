# -*- coding: utf-8 -*-
require 'stringio'
require 'pathname'
require 'enum_util'
require 'encoder'

class IOReader
  def initialize(io, encoder)
    @io = io
    @encoder = encoder
  end
  
  def seek(offset)
    @io.seek(offset)
  end
  
  def each(rs = $/)
    each_with_offset(rs) do |line, line_offset|
      yield line
    end
  end
  
  def each_with_offset(rs = $/)
    offset = 0
    @io.each(rs) do |line|
      yield(@encoder.encode(line.chomp), offset)
      offset = offset + line.size
    end
    offset
  end
end

class InputReader
  def initialize(input, encoder, line_delimiter)
    @input = input
    @encoder = encoder
    @line_delimiter = line_delimiter
  end
  
  def each(rs = $/)
    each_with_offset(rs) do |line, line_offset|
      yield line
    end
  end

  def each_with_offset(rs = $/)
    offset = 0
    buf = ""
    @input.each_read do |data|
      buf << data
      current = 0
      while line_last = buf.index(rs, current)
        line = buf[current ... line_last]

        yield(@encoder.encode(line), offset)

        current = line_last + rs.length
        offset = offset + current
      end
      buf = buf[current .. -1]
    end
    
    yield(@encoder.encode(buf), offset)
  end
end

class InputSource
  include Enumerable
  
  def initialize(input, encoder, line_delimiter)
    @input = input
    @encoder = encoder
    @line_delimiter = line_delimiter
  end
  
  def open
    yield InputReader.new(@input, @encoder, @line_delimiter)
  end
  
  def each(rs = @line_delimiter)
    open do |reader|
      reader.each do |line|
        yield(line)
      end
    end
  end
end


class BytesSource
  include Enumerable
  
  def initialize(bytes, encoder, line_delimiter)
    @bytes = bytes
    @line_delimiter = line_delimiter
    @encoder = encoder
  end
  
  def open
    StringIO.open(@bytes) do |io|
      yield IOReader.new(io, @encoder)
    end
  end
  
  def each(rs = @line_delimiter)
    open do |reader|
      reader.each(rs) do |line|
        yield @encoder.encode(line)
      end
    end
  end
end
