module TwoB
  class Marshaler
    def initialize(file, if_not_exist)
      @file = file
      @if_not_exist = if_not_exist
    end
    
    def load
      begin
        File.open(@file){|io|
          return Marshal.load(io)
        }
      rescue Errno::ENOENT
        return @if_not_exist
      end
    end
    
    def save(object)
      @file.parent.mkpath
      
      File.open(@file, "w") do |io|
        Marshal.dump(object, io)
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
end
