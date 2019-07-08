module Coop
  class Proposals::AcceptsController < CoopController
    load_and_authorize_resource :proposal, parent: false

    expose :proposal

    before_action :set_paper_trail_whodunnit

    def update
      if coop_accepted?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def coop_accepted?
      ProposalService::Coop::Accept.call(proposal: proposal)
    end
  end
end
