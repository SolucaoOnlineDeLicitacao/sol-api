module BiddingsService
  class Waiting
    include Call::Methods
    include TransactionMethods

    def main_method
      change_bidding_to_waiting
    end

    private

    def change_bidding_to_waiting
      execute_or_rollback do
        return false unless bidding.draft?

        bidding.waiting! && bidding.lots.map(&:waiting!)

        Bidding::SpreadsheetReportGenerateWorker.perform_async(bidding.id)

        Notifications::Biddings::WaitingApproval.call(bidding)
      end
    end
  end
end
