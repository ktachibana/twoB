# -*- coding: utf-8 -*-
require 'view_util'

module TwoB
  class BoardView
    include ViewUtil

    def initialize(board, threads)
      @board = board
      @threads = threads
    end

    attr_reader :board
    attr_reader :threads

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
      ; _erbout.concat "\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />\n"
      ; _erbout.concat "\t<meta http-equiv=\"Content-Style-Type\" content=\"text/css\"/>\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\" />\n"
      ; _erbout.concat "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"/board.css\" />\n"
      ; _erbout.concat "\t<title>"; _erbout.concat(( board.url ).to_s); _erbout.concat "</title>\n"
      ; _erbout.concat "</head>\n"
      ; _erbout.concat "<body>\n"
      ; _erbout.concat "<div class=\"flow\">\n"
      ; _erbout.concat "\t<ul class=\"menu\">\n"
      ; _erbout.concat "\t\t<li><a href=\".\">Reload</a></li>\n"
      ; _erbout.concat "\t\t<li><a href=\""; _erbout.concat(( board.url ).to_s); _erbout.concat "\">Original</a></li>\n"
      ; _erbout.concat "\t</ul>\n"
      ; _erbout.concat "</div>\n"
      ; _erbout.concat "<table class=\"threads\">\n"
      ; _erbout.concat "\t<thead class=\"header\">\n"
      ; _erbout.concat "\t\t<tr>\n"
      ; _erbout.concat "\t\t\t<td class=\"no\">No</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"title\">Title</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"count\">Count</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"delete_cache\">D</td>\n"
      ; _erbout.concat "\t\t</tr>\n"
      ; _erbout.concat "\t</thead>\n"
      ; _erbout.concat "\t<tbody class=\"body\">\n"
      ; 	threads.each{|thread|
      _erbout.concat "\t\t<tr class=\""; _erbout.concat(( thread.read? ? 'read' : '' ).to_s); _erbout.concat " "; _erbout.concat(( thread.has_new? ? 'new' : '' ).to_s); _erbout.concat "\">\n"
      ; _erbout.concat "\t\t\t<td class=\"no\">"; _erbout.concat((h thread.order ).to_s); _erbout.concat "</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"title\">\n"
      ; _erbout.concat "\t\t\t\t<a class=\"thread_link\" href=\""; _erbout.concat(( thread.number ).to_s); _erbout.concat "/subscribe5#firstNew\" target=\"_blank\">"; _erbout.concat((h thread.title ).to_s); _erbout.concat "</a>\n"
      ; _erbout.concat "\t\t\t</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"count\">\n"
      ; _erbout.concat "\t\t\t\t"; _erbout.concat(( thread.read_count ).to_s); _erbout.concat " / "; _erbout.concat(( thread.res_count ).to_s)
      if thread.has_new?
      _erbout.concat "\t\t\t\t("; _erbout.concat(( thread.new_count ).to_s); _erbout.concat ")\n"
      ; 		end
      _erbout.concat "\t\t\t</td>\n"
      ; _erbout.concat "\t\t\t<td class=\"delete_cache\">\n"
      ; 		if thread.read?
      _erbout.concat "\t\t\t<a class=\"delete_cache\" href=\""; _erbout.concat(( thread.number ).to_s); _erbout.concat "/delete_cache\">D</a>\n"
      ; 		end
      _erbout.concat "\t\t\t</td>\n"
      ; _erbout.concat "\t\t</tr>\n"
      ; 	}
      _erbout.concat "\t</tbody>\n"
      ; _erbout.concat "</table>\n"
      ; _erbout.concat "</body>\n"
      ; _erbout.concat "</html>\n"
      ; _erbout
    end
  end
end
