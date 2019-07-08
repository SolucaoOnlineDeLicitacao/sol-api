require './lib/dashboards/base'

module Dashboards
  class Cooperative < Base
    private

    def last_biddings
      biddings.limit(LIMIT)
    end
  end
end
