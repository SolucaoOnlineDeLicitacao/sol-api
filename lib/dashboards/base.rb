module Dashboards
  class Base
    attr_accessor :biddings

    LIMIT = 10.freeze

    def initialize(biddings:)
      @biddings = biddings
    end

    def to_json
      { last_biddings: last_biddings.as_json }
    end

    private

    # override
    def last_biddings; end
  end
end
