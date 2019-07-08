module Administrator
  class LotProposals::RefusesController < AdminController
    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot_proposal

    before_action :set_paper_trail_whodunnit

    def update
      if refused?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def refused?
      ProposalService::Admin::LotProposal::Refuse.call(lot_proposal: lot_proposal)
    end
  end
end
