require 'io'

module TwoB
  class Backend
    def get_bytes(request)
      HTTPGetInput.new(request).read()
    end

    def get_subject_source(request, encoder, line_delimiter)
      HTTPGetSource.new(request, encoder, line_delimiter)
    end
  end
end
