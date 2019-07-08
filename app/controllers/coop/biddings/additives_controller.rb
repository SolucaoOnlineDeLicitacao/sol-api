module Coop
  class Biddings::AdditivesController < CoopController
    include CrudController

    load_and_authorize_resource :bidding
    load_and_authorize_resource through: :bidding

    PERMITTED_PARAMS = [:to].freeze

    expose :bidding
    expose :additive

    before_action :associate_bidding
    before_action :set_paper_trail_whodunnit

    def created?
      AdditiveService.call(additive: additive)
    end

    private

    def resource
      additive
    end

    def additive_params
      params.require(:additive).permit(*PERMITTED_PARAMS)
    end

    def associate_bidding
      additive.bidding = bidding
    end
  end
end
