module BiddingsService
  class Finish
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
      generate_minute if finish
      finish
    end

    def finish
      @finish ||= begin
        execute_or_rollback do
          return unless bidding.under_review? && lots_include_valid_statuses?

          recalculate_quantity!

          return desert_and_clone_bidding! if bidding_havent_proposals?

          finish_bidding!
        end
      end
    end

    def desert_and_clone_bidding!
      bidding.desert!
      bidding.reload
      update_bidding_blockchain!
      clone_bidding!
    end

    def finish_bidding!
      bidding.finnished!
      bidding.reload
      create_contract!
      update_bidding_blockchain!
      notify
    end

    def update_bidding_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def lots_include_valid_statuses?
      bidding.lots.map(&:status).all? do |status|
        ['accepted', 'desert', 'failure'].include?(status)
      end
    end

    def bidding_havent_proposals?
      bidding.proposals.not_draft_or_abandoned.empty?
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def generate_minute
      Bidding::Minute::PdfGenerateWorker.perform_async(bidding.id)
    end

    def create_contract!
      ContractsService::Create::Strategy::Finnished.call!(
        bidding: bidding, user: user
      )
    end

    def clone_bidding!
      BiddingsService::Clone.call!(bidding: bidding)
    end

    def notify
      Notifications::Biddings::Finished.call(bidding)
      Notifications::Proposals::Suppliers::All.call(
        proposals: bidding.proposals
      )
    end
  end
end
