module Notifications
  class Biddings::Draw
    include TransactionMethods
    include Call::Methods

    def main_method
      notify
    end

    private

    def notify
      execute_or_rollback do
        Notifications::Biddings::Draw::Admin.call(bidding)
        Notifications::Biddings::Draw::Cooperative.call(bidding)
        Notifications::Biddings::Draw::DrawProvider.call(bidding)
        Notifications::Biddings::Draw::SentProvider.call(bidding)
      end
    end
  end
end
