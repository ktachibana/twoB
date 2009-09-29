require 'erb'

module ViewUtil
  def h(string)
    ERB::Util.html_escape(string).gsub(/\0+/, "?")
  end
end

