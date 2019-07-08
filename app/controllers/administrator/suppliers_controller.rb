module Administrator
  class SuppliersController < AdminController
    include CrudController

    load_and_authorize_resource

    before_action :set_paper_trail_whodunnit
    before_action :skip_password_validation, on: :create

    PERMITTED_PARAMS = [
      :id, :name, :email, :cpf, :phone, :provider_id
    ].freeze

    expose :suppliers, -> { find_suppliers }
    expose :supplier

    private

    def skip_password_validation
      supplier.skip_password_validation!
    end

    def resource
      supplier
    end

    def resources
      suppliers
    end

    def find_suppliers
      Supplier.accessible_by(current_ability)
    end

    def supplier_params
      params.require(:supplier).permit(*PERMITTED_PARAMS)
    end
  end
end
