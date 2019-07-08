class CitySerializer < ActiveModel::Serializer

  attributes :id, :name, :state_name

  def state_name
    object.state.name
  end
end
