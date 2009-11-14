require 'encoder'
require 'io/input'
require 'io/source'

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
    maybe_noentry(nil) do
      @path.delete
    end
  end

  def maybe_noentry(alt_return)
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
