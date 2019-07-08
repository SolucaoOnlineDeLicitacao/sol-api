module Administrator
  class CovenantSerializer < ActiveModel::Serializer
    include CovenantSerializable

    has_many :groups, serializer: Administrator::GroupSerializer
  end
end
