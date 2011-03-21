# -*- coding: utf-8 -*-
require 'stringio'
require 'pathname'
require 'util'
require 'encoder'
require 'net/http'
Net::HTTP.version_1_2

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

class TextFormat
  def initialize(encoding_name, line_delimiter)
    @encoder = Encoder.by_name(encoding_name)
    @line_delimiter = line_delimiter
  end
end

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
        offset += line.length + rs.length
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
  attr_reader :bytes
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

class BinaryFile
  include Input
  def initialize(path, block_size = 1024)
    @path = path
    @block_size = block_size
  end

  def self.by_filename(filename, blocksize = 1024)
    new(Pathname.new(filename), blocksize)
  end

  def each_read
    @path.open("rb") do |io|
      buf = " " * @block_size
      while bytes = io.read(buf.length, buf)
        yield bytes
      end
    end
  end

  def append(append_data)
    @path.parent.mkpath
    @path.open("ab") do |io|
      io.write(append_data)
    end
  end

  def size
    maybe_noentry(0) do
      @path.size
    end
  end

  def delete
    maybe_noentry do
      @path.delete
    end
  end

  def maybe_noentry(alt_return = nil)
    begin
      yield
    rescue Errno::ENOENT
      alt_return
    end
  end
  private :maybe_noentry
end

class TextFile < BinaryFile
  include Enumerable
  def initialize(path, encoding)
    super(path)
    @path = path
    @encoder = Encoder.by_name(encoding)
  end

  def self.by_filename(filename, encoding)
    self.new(Pathname.new(filename), encoding)
  end

  attr_reader :path, :encoder, :offset

  def open
    File.open(@path) do |file|
      yield IOReader.new(file, @encoder)
    end
  end

  def each
    open do |reader|
      reader.each do |line|
        yield line
      end
    end
  end
end

class HTTPGetSource < InputSource
  def initialize(request, encoder, line_delimiter)
    super(HTTPGetInput.new(request), encoder, line_delimiter)
  end
end

class HTTPGetInput
  include Input
  include Net
  def initialize(request)
    @request = request
  end

  def each_read
    HTTP.start(@request.host, @request.port) do |http|
      http.request_get(@request.path, @request.headers) do |response|
        raise ProtocolError, "StatusCode:#{response.code} - #{response.message}, request:#{@request.inspect}" if response.code =~ /[45]../ && response.code != 416
        response.read_body do |data|
          yield data
        end
      end
    end
  end
end

class HTTPRequest
  def initialize(host, port, path, headers)
    @host = host
    @port = port
    @path = path
    @headers = headers
  end
  attr_reader :host, :port, :path, :headers
  equality :@host, :@port, :@path, :@headers
end

class StringInput
  include Input
  def initialize(*bytes_list)
    @bytes_list = bytes_list
  end

  def self.empty
    new()
  end

  def each_read
    @bytes_list.each do |bytes|
      yield bytes
    end
  end
end

class StringSource < BytesSource
  include Enumerable
  def initialize(str)
    super(str, Encoder::Literal, $/)
  end

  def self.empty()
    new("")
  end
end
