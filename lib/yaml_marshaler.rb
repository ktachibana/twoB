require 'yaml'

class YAMLMarshaler
  def initialize(file, if_not_exist)
    @file = file
    @if_not_exist = if_not_exist
  end

  def load
    begin
      File.open(@file){|io|
        return YAML.load(io)
      }
    rescue Errno::ENOENT
      return @if_not_exist
    end
  end

  def save(object)
    @file.parent.mkpath

    File.open(@file, "w") do |io|
      YAML.dump(object, io)
    end
  end

  def update
    object = load
    yield(object)
    save(object)
  end

  def delete
    @file.delete rescue nil
  end
end
