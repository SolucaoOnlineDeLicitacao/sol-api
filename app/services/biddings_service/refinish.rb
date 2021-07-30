module BiddingsService
  class Refinish
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      execute_and_perform
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def execute_and_perform
      generate_addendum_accepted_pdf if refinish
      refinish
    end

    def refinish
      @refinish ||= begin
        execute_or_rollback do
          return unless bidding.reopened? && lots_include_valid_statuses?

          recalculate_quantity!
          bidding.finnished!
          bidding.reload
          update_bidding_blockchain!
          notify
          create_contract!
          generate_spreadsheet_report
        end
      end
    end

    def lots_include_valid_statuses?
      bidding.lots.map(&:status).all? do |status|
        ['accepted', 'desert', 'failure'].include?(status)
      end
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def update_bidding_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def notify
      Notifications::Biddings::Reopened.call(bidding: bidding)
    end

    def create_contract!
      ContractsService::Create::Strategy::Reopened.call!(
        bidding: bidding, user: user
      )
    end

    def generate_addendum_accepted_pdf
      Bidding::Minute::AddendumAcceptedPdfGenerateWorker.perform_async(bidding.id)
    end

    def generate_spreadsheet_report
      Bidding::SpreadsheetReportGenerateWorker.perform_async(bidding.id)
    end
  end
end
