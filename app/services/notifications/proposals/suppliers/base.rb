module Notifications
  class Proposals::Suppliers::Base
    include TransactionMethods
    include Call::Methods

    def main_method
      notify
    end

    private

    def notify
      execute_or_rollback do
        proposals_accepted.each do |proposal|
          Notifications::Proposals::Suppliers::Accepted.call(proposal)
        end
      end
    end

    # override
    def proposals_accepted; end
  end
end
