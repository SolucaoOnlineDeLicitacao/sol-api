module ContractsService
  class Clone::Base
    include TransactionMethods
    include Call::Methods

    delegate :proposal, to: :contract
    delegate :bidding, to: :proposal

    def main_method
      execute_and_perform
    end

    private

    def execute_and_perform
      generate_minute_addendum if change_status_cancel_and_clone
      change_status_cancel_and_clone
    end

    def change_status_cancel_and_clone
      execute_or_rollback do
        change_contract_status!
        cancel_and_clone!
        update_contract_blockchain!
        generate_spreadsheet_report
        notify
      end
    end

    def cancel_and_clone!
      return cancel_and_clone_bidding! if bidding.global?

      cancel_and_clone_lots!
    end

    def cancel_and_clone_bidding!
      BiddingsService::Cancel.call!(bidding: bidding)
      BiddingsService::Clone.call!(bidding: bidding)
    end

    def cancel_and_clone_lots!
      LotsService::Cancel.call!(proposal: proposal)
      LotsService::Clone.call!(proposal: proposal)
    end

    def generate_spreadsheet_report
      Bidding::SpreadsheetReportGenerateWorker.perform_async(bidding.id)
    end

    def generate_minute_addendum
      Bidding::Minute::AddendumPdfGenerateWorker.perform_async(contract.id)
    end

    def update_contract_blockchain!
      Blockchain::Contract::Update.call!(contract: contract)
    end

    # override for notification
    def notify; end
  end
end
