module Notifications
  class Proposals::Suppliers::Segmented < Proposals::Suppliers::Base
    private

    def proposals_accepted
      proposals.accepteds_without_contracts
    end
  end
end
