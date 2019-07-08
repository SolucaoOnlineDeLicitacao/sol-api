module Supp
  class LotProposalImportSerializer < ActiveModel::Serializer
    include BaseProposalImportSerializer

    attributes :lot_id, :lot_name

    def lot_id
      object.lot.id
    end

    def lot_name
      object.lot.name
    end
  end
end
