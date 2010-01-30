require 'twob/thread'
require 'twob/thread/delta'

module JBBS
  class DeltaBuilder
    include TwoB
    include TwoB::Dat
      
    def initialize(source)
      @source = source
      @thread_title = ""
      @res_list = []
      @index = {}
    end
    
    def build
      parser = TwoB::DatParser.new
      parser.each_line_with_index(@source) do |values, offset|
        number = values[0].to_i
        name_string = values.fetch(1, "")
        name_match = TRIP_PATTERN.match(name_string)
        name = name_match ? name_match[1] : name_string
        trip = name_match ? name_match[3] : nil
        mail = values.fetch(2, "")
        date = values.fetch(3, "")
        body_text = values.fetch(4, "")
        id = values.fetch(6, "")
        @thread_title = values[5] if values[5]
        
        @res_list << TwoB::DatRes.new(number, name, trip, mail, date, id, parse_body(body_text))
        @index[number] = offset
      end
      TwoB::Delta.new(Dat::Content.new(@thread_title, @res_list), @index)
    end
  end
end
