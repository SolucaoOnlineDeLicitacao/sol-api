class Address < ApplicationRecord
  # skips some validations if integrated
  attr_accessor :skip_integration_validations

  versionable

  belongs_to :addressable, polymorphic: true
  belongs_to :city, optional: :city_optional?

  has_one :state, through: :city

  validates :address,
            :number,
            :neighborhood,
            :reference_point,
            presence: true

  with_options unless: -> { skip_integration_validations } do |model|
    model.validates :cep, zip_code: true
    model.validates :latitude, latitude: true
    model.validates :longitude, longitude: true

    model.validates :latitude,
                    :longitude,
                    :cep,
                    :city,
                    presence: true
  end

  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :state, prefix: true, allow_nil: true

  def skip_integration_validations!
    @skip_integration_validations = true
  end

  private

  def city_optional?
    !! @skip_integration_validations
  end

end
