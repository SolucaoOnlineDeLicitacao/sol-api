class EventProviderAccessSerializer < ActiveModel::Serializer
  attributes :id, :eventable_type, :eventable_id, :creator_type, :creator_id,
             :creator_name, :data, :created_at

  def creator_name
    object.creator.name
  end
end
