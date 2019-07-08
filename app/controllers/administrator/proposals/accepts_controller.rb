module Administrator
  class Proposals::AcceptsController < AdminController
    load_and_authorize_resource :proposal, parent: false

    expose :proposal

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
      ProposalService::Admin::Accept.call(proposal: proposal)
    end
  end
end
