module Notifications
  class Biddings::FailureAll
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      notify
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def notify
      execute_or_rollback do
        Notifications::Biddings::Failure::All::Admin.call(bidding)
        Notifications::Biddings::Failure::All::Provider.call(bidding)
        Notifications::Biddings::Failure::All::Cooperative.call(bidding)
      end
    end

  end
end
