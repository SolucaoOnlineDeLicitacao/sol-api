module Coop
  module Biddings
    class Invites::ReprovesController < CoopController
      include TransactionMethods

      load_and_authorize_resource :invite, parent: false

      expose :invite
      expose :bidding

      before_action :set_paper_trail_whodunnit

      def update
        if reproves
          render status: :ok
        else
          render status: :unprocessable_entity, json: { errors: @event.errors_as_json }
        end
      end

      private

      def reproves
        execute_or_rollback do
          @event = Events::InviteReproved.new(attributes)
          @event.save!

          invite.reproved! && invite.reload

          Notifications::Invites::Reproved.call(invite)
        end
      end

      def attributes
        {
          from: invite.status,
          to: 'reproved',
          comment: params[:comment],
          eventable: invite,
          creator: current_user
        }
      end
    end
  end
end
