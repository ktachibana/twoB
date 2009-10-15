require 'twob/board/subject'

module TwoB
  class SubjectParser
    def initialize(line_pattern)
      @line_pattern = line_pattern
    end
    
    def parse(source)
      result = []
      source.each_with_index do |line, index|
        next if line.empty?
        match = @line_pattern.match(line)
        unless match
          result << ThreadSubject::Item.new(index + 1, "", "?")
          next
        end
        number = match[1]
        title = match[2]
        res_count = match[3].to_i
        result << ThreadSubject::Item.new(index + 1, number, title, res_count)
      end
      result
    end
  end

end
