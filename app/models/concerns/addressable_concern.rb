module AddressableConcern
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable, dependent: :destroy

    accepts_nested_attributes_for :address

    scope :by_viewport, ->(bounds) do
      joins(:address).where(addresses: { latitude: bounds.south..bounds.north, longitude: bounds.west..bounds.east })
    end
  end

end
