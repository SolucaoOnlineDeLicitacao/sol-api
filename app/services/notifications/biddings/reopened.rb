module Notifications
  class Biddings::Reopened
    include TransactionMethods
    include Call::Methods

    def main_method
      notify
    end

    private

    def notify
      execute_or_rollback do
        bidding.global? ? notify_global : segmented_notify
      end
    end

    def notify_global
      Notifications::Biddings::Finished.call(bidding)
      Notifications::Proposals::Suppliers::All.call(proposals: bidding.proposals)
    end

    def segmented_notify
      Notifications::Biddings::Finished.call(bidding)
      Notifications::Proposals::Suppliers::Segmented.call(proposals: bidding.proposals)
    end
  end
end
