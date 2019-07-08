module Coop
  class Covenants::GroupsController < CoopController
    load_and_authorize_resource :group, parent: false

    expose :covenant
    expose :groups, -> { find_groups }
    expose :group

    def index
      render json: groups, each_serializer: Coop::GroupSerializer
    end

    def show
      render json: group, serializer: Coop::GroupSerializer
    end

    private

    def find_groups
      covenant.groups.accessible_by(current_ability)
    end

    def resource
      group
    end
  end
end
