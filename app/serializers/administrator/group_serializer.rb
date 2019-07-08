module Administrator
  class GroupSerializer < ActiveModel::Serializer
    include GroupSerializable

    has_many :group_items, serializer: Administrator::GroupItemSerializer
  end
end
