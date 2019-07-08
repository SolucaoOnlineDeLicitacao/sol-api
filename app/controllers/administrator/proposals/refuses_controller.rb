module Administrator
  class Proposals::RefusesController < AdminController
    load_and_authorize_resource :proposal, parent: false

    expose :proposal

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
      ProposalService::Admin::Refuse.call(proposal: proposal)
    end
  end
end
