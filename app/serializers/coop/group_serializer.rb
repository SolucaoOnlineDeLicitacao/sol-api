module Coop
  class GroupSerializer < ActiveModel::Serializer
    include GroupSerializable

    has_many :group_items, serializer: Coop::GroupItemSerializer
  end
end
