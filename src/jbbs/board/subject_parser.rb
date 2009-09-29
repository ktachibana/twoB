require 'twob/subject'

module JBBS
  class BoardSubjectParser
    def parse(source)
      result = []
      source.each_with_index do |line, index|
        match = /^(\d+)\.cgi,(.+)\((\d+)\)$/.match(line)
        raise line unless match # TODO
        number = match[1]
        title = match[2]
        res_count = match[3].to_i
        result << TwoB::ThreadSubjectItem.new(index + 1, number, title, res_count)
      end
      result
    end
  end
  
end
