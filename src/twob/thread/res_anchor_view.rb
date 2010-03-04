# -*- coding: utf-8 -*-
require 'util'

module TwoB
  class ResAnchorView
    include ViewUtil
  
    def initialize(res_list)
      @res_list = res_list
    end

    attr_reader :res_list
  
    def status_code
      200
    end
    
    def content_type
      "text/html; charset=UTF-8"
    end
    
    def headers
      {"Content-Type" => content_type}
    end
  
    def write_body(_erbout)
      def _erbout.concat(str)
        self << str
      end
  
      _erbout.concat "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n"
      ; _erbout.concat "<html>\n"
      ; _erbout.concat "<head>\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/twoB/web/style.css\" />\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/twoB/web/thread.css\" />\n"
      ; _erbout.concat "\t<script type=\"text/javascript\" src=\"/twoB/web/popup.js\"></script>\n"
      ; _erbout.concat "</head>\n"
      ; _erbout.concat "<body onload=\"javascript: b2rPopup.startup();\">\n"
      ;  res_list.each{|res|
      _erbout.concat "\t<div id=\"_"; _erbout.concat(( res.number ).to_s); _erbout.concat "\" class=\"res\" style=\""; _erbout.concat(( !res.visible? ? 'display: none;' : '' ).to_s); _erbout.concat "\">\n"
      ; _erbout.concat "\t\t<dl class=\""; _erbout.concat(( res.new? ? 'new' : '' ).to_s); _erbout.concat " "; _erbout.concat((h res.age? ? 'age' : '' ).to_s); _erbout.concat "\">\n"
      ; _erbout.concat "\t\t\t<dt class=\"header\">\n"
      ; _erbout.concat "\t\t\t\t<span class=\"number\">"; _erbout.concat(( res.number ).to_s); _erbout.concat "</span>\n"
      ; _erbout.concat "\t\t\t\t<span class=\"name\">"; _erbout.concat(( res.name ).to_s);  if res.has_trip? then ; _erbout.concat " <span class=\"trip\">\342\227\206"; _erbout.concat((h res.trip ).to_s); _erbout.concat "</span>";  end ; _erbout.concat "</span>\n"
      ; _erbout.concat "\t\t\t\t[<span class=\"mail\">"; _erbout.concat((h res.mail ).to_s); _erbout.concat "</span>]\n"
      ; _erbout.concat "\t\t\t\tDate:<span class=\"date\">"; _erbout.concat((h res.date ).to_s); _erbout.concat "</span>\n"
      ; _erbout.concat "\t\t\t\tID:<span class=\"id\">"; _erbout.concat((h res.id ).to_s); _erbout.concat "</span>\n"
      ; _erbout.concat "\t\t\t\t<span class=\"bookmark\">[<a href=\""; _erbout.concat(( res.number ).to_s); _erbout.concat "/bookmark\">\346\240\236</a>]</span>\n"
      ; _erbout.concat "\t\t\t</dt>\n"
      ; _erbout.concat "\t\t\t<dd class=\"body\">\n"
      ; 	res.body.each{|body|
      case body.body_type
      when :anchor
      ; _erbout.concat "<a href=\"#_"; _erbout.concat(( body.top_id ).to_s); _erbout.concat "\" class=\"anchor\" onmouseover=\"b2rPopup.resPopup.mouseOver(event, "; _erbout.concat(( body.top_id ).to_s); _erbout.concat ", "; _erbout.concat(( body.bottom_id ).to_s); _erbout.concat ", b2rPopup.resPopup.remote);\">"; _erbout.concat((h body ).to_s); _erbout.concat "</a>";
      when :link
      ; _erbout.concat "<a href=\""; _erbout.concat((h body.url ).to_s); _erbout.concat "\" class=\""; _erbout.concat(( body.link_type ).to_s); _erbout.concat "\" target=\"_blank\">"; _erbout.concat((h body ).to_s); _erbout.concat "</a>";
      when :break_line
      ; _erbout.concat "<br/>\n"
      ; 		else
      ; _erbout.concat(( body ).to_s);
      end
      }
      _erbout.concat "\n"
      ; _erbout.concat "\t\t\t</dd>\n"
      ; _erbout.concat "\t\t</dl>\n"
      ; _erbout.concat "\t</div>\n"
      ;  }
      _erbout.concat "</body>\n"
      ; _erbout.concat "</html>\n"
      ; _erbout
    end
  end
end
