module Supp
  module Biddings
    class Invites::OpenController < SuppController
      include CrudController

      before_action :assign_parents
      before_action :set_paper_trail_whodunnit

      load_and_authorize_resource :bidding
      load_and_authorize_resource :invite, through: :bidding

      expose :invite
      expose :bidding

      private

      def assign_parents
        resource.provider = current_provider
        resource.bidding = bidding
      end

      def resource
        invite
      end
    end
  end
end
