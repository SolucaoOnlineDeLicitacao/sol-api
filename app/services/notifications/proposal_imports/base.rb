module Notifications
  class ProposalImports::Base < Base
    include Call::Methods

    def main_method
      notify
    end

    private

    def body_args
      [bidding.title, proposal_import.file.filename]
    end

    def receivables
      supplier
    end

    def notifiable
      proposal_import
    end

    def extra_args
      { bidding_id: bidding.id }
    end

    def bidding
      @bidding ||= proposal_import.bidding
    end
  end
end
