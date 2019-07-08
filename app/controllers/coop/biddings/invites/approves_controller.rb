module Coop
  module Biddings
    class Invites::ApprovesController < CoopController
      include TransactionMethods

      load_and_authorize_resource :invite, parent: false

      expose :invite
      expose :bidding

      before_action :set_paper_trail_whodunnit

      def update
        if accept
          render status: :ok
        else
          render status: :unprocessable_entity
        end
      end

      private

      def accept
        execute_or_rollback do
          invite.approved! && invite.reload

          Notifications::Invites::Approved.call(invite)
        end
      end
    end
  end
end
