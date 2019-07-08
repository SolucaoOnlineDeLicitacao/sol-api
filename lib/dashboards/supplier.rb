require './lib/dashboards/base'

module Dashboards
  class Supplier < Base
    private

    def last_biddings
      biddings[0..LIMIT-1]
    end
  end
end
