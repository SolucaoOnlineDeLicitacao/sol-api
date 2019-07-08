class ProvidersController < ApplicationController
  include CrudController

  PERMITTED_PARAMS = [
    :name, :document, :type,

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
    ],

    provider_classifications_attributes: [
      :id, :classification_id, :_destroy
    ],

    suppliers_attributes: [
      :name, :email, :phone, :cpf, :password, :password_confirmation
    ],

    attachments_attributes: [
      :id, :file, :_destroy
    ]
  ].freeze

  expose :provider

  private

  def resource
    provider
  end

  def resource_key
    :provider
  end

  def provider_params
    params.require(:provider).permit(*PERMITTED_PARAMS)
  end
end
