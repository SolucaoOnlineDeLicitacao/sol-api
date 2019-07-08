module Supp
  class ContractSerializer < ActiveModel::Serializer
    include BaseContractSerializer

    attributes :cooperative_title

    def cooperative_title
      object.user.cooperative.name
    end

  end
end
