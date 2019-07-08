class Maps
  attr_reader :resource, :collection_klass

  def initialize(resource:, collection_klass:)
    @resource = resource
    @collection_klass = collection_klass
  end

  def to_json
    { markers: markers.as_json }
  end

  private

  def collection
    @collection ||= collection_klass.includes(:address).where.not(addresses: { latitude: nil, longitude: nil })
  end

  def markers
    collection.inject([resource_as_json(resource)]) do |array, current_resource|
      array << resource_as_json(current_resource)
    end
  end

  def resource_as_json(resource)
    { 
      id: resource.id,
      type: resource.class.base_class.to_s.downcase,
      position: position(resource.address),
      text: resource.name,
      title: resource.name
    }
  end

  def position(address)
    { lat: address.latitude.to_f, lng: address.longitude.to_f }
  end
end