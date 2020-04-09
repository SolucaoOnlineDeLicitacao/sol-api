module Coop
  class Biddings::LotsController < CoopController
    include CrudController

    load_and_authorize_resource :bidding, only: :create
    load_and_authorize_resource :lot, through: :bidding, only: :create

    load_and_authorize_resource :lot, except: :create

    before_action :ensure_bidding, only: :create
    before_action :set_paper_trail_whodunnit

    PERMITTED_PARAMS = [
      :id, :name, :deadline, :address,

      lot_group_items_attributes: [
        :id, :group_item_id, :quantity, :_destroy
      ],

      attachments_attributes: [
        :id, :file, :_destroy
      ]
    ].freeze

    expose :bidding
    expose :lots, -> { find_lots }
    expose :lot

    def index
      render json: paginated_resources, each_serializer: Coop::LotSerializer
    end

    def show
      render json: resource, serializer: Coop::LotSerializer
    end

    private

    def created?
      ActiveRecord::Base.transaction do
        super && RecalculateQuantityService.call!(covenant: bidding.covenant)

      rescue => error
        raise ActiveRecord::Rollback
        return false
      end
    end

    def updated?
      ActiveRecord::Base.transaction do
        super && RecalculateQuantityService.call!(covenant: bidding.covenant)

      rescue => error
        raise ActiveRecord::Rollback
        return false
      end
    end

    def failure_errors
      resource.errors_as_json
        .merge(lot_group_items_errors: resource.lot_group_items.map(&:errors_as_json))
    end

    def ensure_bidding
      resource.bidding = bidding
    end

    def find_lots
      bidding.lots.accessible_by(current_ability)
    end

    def resource
      lot
    end

    def resources
      lots
    end

    def lot_params
      params.require(:lot).permit(*PERMITTED_PARAMS)
    end
  end
end
