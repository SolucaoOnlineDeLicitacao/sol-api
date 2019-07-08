module Administrator
  class ItemsController < AdminController
    include CrudController

    load_and_authorize_resource

    before_action :ensure_classification, only: [:create, :update]
    before_action :assign_owner, only: [:create]
    before_action :set_paper_trail_whodunnit

    PERMITTED_PARAMS = [
      :code, :title, :description, :unit_id, :classification_id, :children_classification_id
    ].freeze

    expose :items, -> { find_items }
    expose :item

    private

    def ensure_classification
      return unless params[:item].present?
      params[:item][:classification_id] = params[:item][:children_classification_id] if children_classification?
      params[:item].delete(:children_classification_id)
    end

    def children_classification?
      params[:item][:children_classification_id] != '0' &&
      params[:item][:children_classification_id].present?
    end

    def assign_owner
      item.owner = current_user
    end

    def resource
      item
    end

    def resources
      items
    end

    def find_items
      Item.accessible_by(current_ability).includes(:owner, :classification)
    end

    def item_params
      params.require(:item).permit(*PERMITTED_PARAMS)
    end
  end
end
