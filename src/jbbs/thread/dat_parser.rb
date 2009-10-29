require 'twob/thread'

module JBBS
  class DatParser < TwoB::DatParser
    include TwoB::Dat
    
    def on_start_part(part)
      
    end
    
    def parse_line(values)
      number = values[0].to_i
      name_string = values.fetch(1, "")
      name_match = TRIP_PATTERN.match(name_string)
      name = name_match ? name_match[1] : name_string
      trip = name_match ? name_match[3] : nil
      mail = values.fetch(2, "")
      date = values.fetch(3, "")
      body_text = values.fetch(4, "")
      id = values.fetch(6, "")
      @thread_title = values.fetch(5, "") if number == 1
      @res_list << TwoB::DatRes.new(number, name, trip, mail, date, id, parse_body(body_text))
    end
  end
end
