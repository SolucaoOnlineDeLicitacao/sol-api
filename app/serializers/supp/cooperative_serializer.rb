module Supp
  class CooperativeSerializer < ActiveModel::Serializer
    attributes :id, :name, :cnpj, :address

    # has_one :address, serializer: AddressSerializer
    # forces to send address
    def address
      AddressSerializer.new(object.address)
    end
  end
end
