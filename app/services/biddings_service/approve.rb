module BiddingsService
  class Approve
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
      generate_import_file_and_edict if approve
      approve
    end

    def approve
      @approve ||= begin
        execute_or_rollback do
          bidding.approved!
          bidding.reload
          create_bidding_at_blockchain!
          notify
        end
      end
    end

    def create_bidding_at_blockchain!
      response = Blockchain::Bidding::Create.call(bidding)
      raise BlockchainError unless response.success?
    end

    def notify
      Notifications::Biddings::Approved.call(bidding)
    end

    def generate_import_file_and_edict
      generate_import_file
      generate_edict
    end

    def generate_import_file
      Bidding::ProposalImportFileGenerateWorker.perform_async(bidding.id)

      bidding.lots.each do |lot|
        # one each so if one fails it doesnt regenerate all of them
        Bidding::LotProposalImportFileGenerateWorker.perform_async(
          bidding.id, lot.id
        )
      end
    end

    def generate_edict
      Bidding::EdictPdfGenerateWorker.perform_async(bidding.id)
    end
  end
end
