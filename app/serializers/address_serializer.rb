class AddressSerializer < ActiveModel::Serializer

  attributes :id, :latitude, :longitude, :city_name, :city_id, :address,
              :number, :neighborhood, :cep, :complement, :reference_point

  belongs_to :city

  def latitude
    object.latitude.to_s
  end

  def longitude
    object.longitude.to_s
  end

  def city_name
    object.city_name
  end
end
