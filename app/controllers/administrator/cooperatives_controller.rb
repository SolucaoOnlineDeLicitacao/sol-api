module Administrator
  class CooperativesController < AdminController
    include CrudController

    load_and_authorize_resource

    PERMITTED_PARAMS = [
      :name, :cnpj,

      address_attributes: [
        :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
        :reference_point, :latitude, :longitude
      ],

      legal_representative_attributes: [
        :id, :name, :nationality, :civil_state, :rg, :cpf, :valid_until,

        address_attributes: [
          :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
          :reference_point, :latitude, :longitude
        ]

      ]
    ].freeze

    expose :cooperatives, -> { find_cooperatives }
    expose :cooperative

    before_action :set_paper_trail_whodunnit

    private

    def resource
      cooperative
    end

    def resources
      cooperatives
    end

    def find_cooperatives
      Cooperative.accessible_by(current_ability).includes(:address)
    end

    def cooperative_params
      params.require(:cooperative).permit(*PERMITTED_PARAMS)
    end
  end
end
