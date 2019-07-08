module Notifications
  class ProposalImports::Lots::Base < ProposalImports::Base
    private

    def body_args
      [lot.name, lot_proposal_import.file.filename]
    end

    def receivables
      supplier
    end

    def notifiable
      lot_proposal_import
    end

    def extra_args
      { bidding_id: bidding.id, lot_id: lot.id }
    end

    def bidding
      @bidding ||= lot_proposal_import.bidding
    end

    def lot
      @lot ||= lot_proposal_import.lot
    end
  end
end
