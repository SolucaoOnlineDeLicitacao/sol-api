module Notifications
  class Proposals::Suppliers::All < Proposals::Suppliers::Base
    private

    def proposals_accepted
      proposals.accepted
    end
  end
end
