# -*- coding: utf-8 -*-
require 'util/view'

module TwoB
  class StartPageView
    include ViewUtil

    def initialize(request)
      @request = request
    end

    attr_reader :request

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

      _erbout.concat "<html>\n"
      ; _erbout.concat "<head>\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />\n"
      ; _erbout.concat "\t<title>twoB</title>\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\" />\n"
      ; _erbout.concat "</head>\n"
      ; _erbout.concat "\n"
      ; _erbout.concat "<body>\n"
      ; _erbout.concat "  <p>\n"
      ; _erbout.concat "    Bookmarklet: <a class=\"bookmarklet\" href=\"javascript:location.href='"; _erbout.concat(( request.request_script ).to_s); _erbout.concat "/show?url='+encodeURI(location.href)\">twoB\343\201\247\350\241\250\347\244\272</a>\n"
      ; _erbout.concat "  </p>\n"
      ; _erbout.concat "  <form action=\""; _erbout.concat(( request.script_name ).to_s); _erbout.concat "/show\" method=\"get\">\n"
      ; _erbout.concat "    URL: <input type=\"text\" name=\"url\"/>\n"
      ; _erbout.concat "    <input type=\"submit\" value=\"twoB\343\201\247\350\241\250\347\244\272\"/>\n"
      ; _erbout.concat "  </form>\n"
      ; _erbout.concat "</body>\n"
      ; _erbout.concat "</html>\n"
      ; _erbout
    end
  end
end
