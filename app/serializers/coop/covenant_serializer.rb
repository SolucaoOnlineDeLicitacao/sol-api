module Coop
  class CovenantSerializer < ActiveModel::Serializer
    include CovenantSerializable

    has_many :groups, serializer: Coop::GroupSerializer
  end
end
