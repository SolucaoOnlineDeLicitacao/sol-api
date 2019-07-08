module Coop
  class Contract::ItemsController < CoopController
    include CrudController

    load_and_authorize_resource :lot_group_item, parent: false

    expose :contract
    expose :lot_group_items, -> { find_lot_group_items }

    def index
      render json: lot_group_items, each_serializer: Coop::LotGroupItemSerializer
    end

    private

    def find_lot_group_items
      contract.lot_group_items.accessible_by(current_ability)
    end

    def resource
      contract
    end
  end
end
