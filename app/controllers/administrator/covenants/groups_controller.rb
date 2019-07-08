module Administrator
  class Covenants::GroupsController < AdminController
    include CrudController

    load_and_authorize_resource :group, parent: false

    before_action :ensure_covenant, only: :create
    before_action :set_paper_trail_whodunnit

    PERMITTED_PARAMS = [
      :id, :name, group_items_attributes: [
        :id, :item_id, :quantity, :estimated_cost, :_destroy
      ]
    ].freeze

    expose :covenant
    expose :group

    def show
      render json: resource, serializer: Administrator::GroupSerializer
    end

    private

    def failure_errors
      resource.errors_as_json
        .merge(group_items_errors: resource.group_items.map(&:errors_as_json))
    end

    def ensure_covenant
      resource.covenant = covenant
    end

    def resource
      group
    end

    def group_params
      params.require(:group).permit(*PERMITTED_PARAMS)
    end
  end
end
