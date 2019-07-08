module Administrator
  class LotProposals::AcceptsController < AdminController
    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot_proposal

    before_action :set_paper_trail_whodunnit

    def update
      if accepted?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def accepted?
      ProposalService::Admin::LotProposal::Accept.call(lot_proposal: lot_proposal)
    end
  end
end
