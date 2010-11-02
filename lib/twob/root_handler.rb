require 'bbs2ch/host'
require 'jbbs/host'
require 'twob/error_view'
require 'twob/start_page_view'
require 'twob/handler'
require 'util/enum'
require 'forwardable'

module TwoB
  class RootHandler
    extend Forwardable
    include Handler
    def initialize(configuration, backend)
      @configuration = configuration
      @backend = backend
    end

    attr_reader :configuration
    def_delegators(:@backend, :get_delta_input, :get_subject_source)

    def execute(request, value)
      case value
      when "show"
        show(request.script_name, request.get_param("url"))
      when ""
        start_page(request)
      end
    end

    def /(value)
      case value
      when JBBS::Host::Name then JBBS::Host.new(self)
      when BBS2ch::Host.NamePattern then BBS2ch::Host.new(self, value)
      when "" then self
      else super
      end
    end

    def start_page(request)
      StartPageView.new(request)
    end

    def show(script_name, url)
      path = [JBBS::Host, BBS2ch::Host].find_not_nil do |host|
        host.get_path(url)
      end
      raise "#{url}を処理することができません" unless path
      RedirectResponse.new(script_name + path)
    end
  end
end
