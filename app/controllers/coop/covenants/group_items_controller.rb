module Coop
  class Covenants::GroupItemsController < CoopController
    include CrudController

    load_and_authorize_resource :group_item, parent: false

    expose :covenant
    expose :group_items, -> { find_group_items }
    expose :group_item

    def index
      render json: paginated_resources, each_serializer: Administrator::GroupItemSerializer
    end

    private

    def find_group_items
      GroupItem.by_covenant(covenant.id).accessible_by(current_ability)
    end

    def resources
      group_items
    end
  end
end
