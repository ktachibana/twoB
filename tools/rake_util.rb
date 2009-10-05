require 'rake'

class Rake::FileList
  def mapping
    result = {}
    self.each do |source|
      result[source] = yield(source)
    end
    
    def result.sources
      self.keys
    end
    def result.objects
      self.values
    end
    result
  end
end

