require 'util/view'

class DatView
  include ViewUtil
  def initialize(dat)
    @dat = dat
  end

  attr_reader :dat

  def status_code
    200
  end

  def content_type
    "text/plain; charset=UTF-8"
  end

  def headers
    {"Content-Type" => content_type}
  end

  def write(_erbout)
    def _erbout.concat(str)
      self << str
    end

    dat.each_res do |res|
      _erbout.concat "\n"
      ; _erbout.concat "--------------------------------------------------------------\n"
      ; _erbout.concat "\n"
      ; _erbout.concat(( res.number ).to_s); _erbout.concat ": "; _erbout.concat(( res.name ).to_s);  if res.has_trip? ; _erbout.concat "\342\227\206"; _erbout.concat((h res.trip ).to_s);  end ; _erbout.concat " ["; _erbout.concat((h res.mail ).to_s); _erbout.concat "] Date:"; _erbout.concat((h res.date ).to_s); _erbout.concat " ID:"; _erbout.concat((h res.id ).to_s)
      _erbout.concat "\n"
      ;     res.body.each do |body|
        case body.body_type
        when :anchor
          _erbout.concat(( body ).to_s);
        when :link
          _erbout.concat "["; _erbout.concat(( body ).to_s); _erbout.concat "]";
        when :break_line
          _erbout.concat "\n"
          ;       else
          _erbout.concat(( body ).to_s);
        end
      end
    end
    _erbout
  end
end
