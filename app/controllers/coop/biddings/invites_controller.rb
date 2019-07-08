module Coop
  class Biddings::InvitesController < CoopController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    expose :bidding
    expose :invites, -> { bidding.invites }

    def index
      render json: invites, each_serializer: Coop::InviteSerializer
    end

    private

    def resources
      invites
    end
  end
end
