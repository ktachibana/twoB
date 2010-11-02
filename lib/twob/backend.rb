require 'io/http'

module TwoB
  class Backend
    def get_delta_input(request)
      HTTPGetInput.new(request)
    end

    def get_subject_source(request, encoder, line_delimiter)
      HTTPGetSource.new(request, encoder, line_delimiter)
    end
  end
end
