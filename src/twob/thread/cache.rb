require 'twob/thread/dat/dat_content'

module TwoB
  class Cache
    def initialize(dat_content)
      @dat_content = dat_content
    end

    Empty = self.new(TwoB::Dat::Content::Empty)

    attr_reader :dat_content

    def new_number
      @dat_content.empty? ? 1 : @dat_content.last_res_number + 1
    end

    def title
      @dat_content.title
    end

    def has_title?
      @dat_content.has_title?
    end

    def each_res
      @dat_content.each_res do |res|
        yield res
      end
    end

    def res_count
      @dat_content.res_count
    end

    def last_number
      @dat_content.last_res_number
    end

    def range
      @dat_content.range
    end
  end
end