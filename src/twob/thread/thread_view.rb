# -*- coding: utf-8 -*-
require 'util/view'

module TwoB
  class ThreadView
    include ViewUtil
    def initialize(thread)
      @thread = thread
    end

    attr_reader :thread

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
      ; _erbout.concat "\t<title>"; _erbout.concat((h thread.title ).to_s); _erbout.concat "</title>\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/twoB/web/style.css\" />\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/twoB/web/thread.css\" />\n"
      ; _erbout.concat "\t<script type=\"text/javascript\" src=\"/twoB/web/jquery-1.3.1.js\"></script>\n"
      ; _erbout.concat "\t<script type=\"text/javascript\" src=\"/twoB/web/popup.js\"></script>\n"
      ; _erbout.concat "</head>\n"
      ; _erbout.concat "\n"
      ; _erbout.concat "<body onload=\"javascript: b2rPopup.startup();\">\n"
      ; _erbout.concat "\t<div class=\"flow\">\n"
      ; _erbout.concat "\t\t<h1 id=\"title\" class=\"title\">"; _erbout.concat((h thread.title ).to_s); _erbout.concat "</h1>\n"
      ; _erbout.concat "\t\t<ul class=\"menu\">\n"
      ; _erbout.concat "\t\t\t<li><a href=\"../\">\343\202\271\343\203\254\343\203\203\343\203\211\344\270\200\350\246\247</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a href=\"./\">\345\205\250\344\273\266\350\241\250\347\244\272</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a href=\"./subscribe5\">\346\226\260\347\235\200</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a href=\"#firstNew\">\346\226\260\347\235\200\343\201\253\347\247\273\345\213\225</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a href=\"./delete_cache?reload\">\343\202\255\343\203\243\343\203\203\343\202\267\343\203\245\343\202\222\345\206\215\350\252\255\343\201\277\350\276\274\343\201\277</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a href=\""; _erbout.concat((h thread.original_url ).to_s); _erbout.concat "l50\" target=\"_blank\">\343\203\226\343\203\251\343\202\246\343\202\266\350\241\250\347\244\272</a></li>\n"
      ; _erbout.concat "\t\t\t<li><a id=\"view_dat_file\" href=\""; _erbout.concat((h thread.dat_url ).to_s); _erbout.concat "\" target=\"_blank\">dat\343\203\225\343\202\241\343\202\244\343\203\253\350\241\250\347\244\272</a></li>\n"
      ;  if thread.bookmarking?
        _erbout.concat "\t\t\t<li><a href=\"delete_bookmark\">\343\203\226\343\203\203\343\202\257\343\203\236\343\203\274\343\202\257\343\202\222\345\211\212\351\231\244</a></li>\n"
        ;  end
      _erbout.concat "\t\t</ul>\n"
      ; _erbout.concat "\t</div>\n"
      ; _erbout.concat "\n"
      ;  thread.each{|res|
        _erbout.concat "\t<div id=\"_"; _erbout.concat(( res.number ).to_s); _erbout.concat "\" class=\"res\">\n"
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
            ; _erbout.concat "<a href=\"#_"; _erbout.concat(( body.top_id ).to_s); _erbout.concat "\" class=\"anchor\" onmouseover=\"b2rPopup.resPopup.mouseOver(event, "; _erbout.concat(( body.top_id ).to_s); _erbout.concat ", "; _erbout.concat(( body.bottom_id ).to_s); _erbout.concat ", "; _erbout.concat(( thread.visible_all?(body) ? "b2rPopup.resPopup.local" : "b2rPopup.resPopup.remote" ).to_s); _erbout.concat ");\">"; _erbout.concat((h body ).to_s); _erbout.concat "</a>";
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
        ; 	if thread.read_number == res.number
          _erbout.concat "\t<hr id=\"firstNew\" />\n"
          ; 	end
      }
      _erbout.concat "</body>\n"
      ; _erbout.concat "</html>\n"
      ; _erbout
    end
  end
end
