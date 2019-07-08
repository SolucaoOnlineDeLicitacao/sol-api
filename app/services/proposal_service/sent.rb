module ProposalService
  class Sent
    include TransactionMethods

    attr_reader :proposal

    def initialize(proposal)
      @proposal = proposal
    end

    def self.call(proposal)
      new(proposal).call
    end

    def call
      sent_and_blockchain_create!
    end

    private

    def sent_and_blockchain_create!
      execute_or_rollback do
        update_sent_updated_at
        # order matters here
        proposal.sent!
        raise BlockchainError unless create_or_update_blockchain?
      end
    end

    def update_sent_updated_at
      proposal.update!(sent_updated_at: DateTime.current)
    end

    def create_or_update_blockchain?
      return blockchain_update if blockchain_get.success?

      blockchain_create
    end

    def blockchain_get
      Blockchain::Proposal::Get.call(proposal)
    end

    def blockchain_update
      Blockchain::Proposal::Update.call(proposal).success?
    end

    def blockchain_create
      Blockchain::Proposal::Create.call(proposal).success?
    end
  end
end
