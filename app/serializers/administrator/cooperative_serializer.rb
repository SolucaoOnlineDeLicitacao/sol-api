module Administrator
  class CooperativeSerializer < ActiveModel::Serializer
    attributes :id, :name, :cnpj, :legal_representative, :covenants

    has_one :address

    # has_many :covenants, serializer: Administrator::CovenantSerializer
    # forces to send associations
    def covenants
      object.covenants.map do |covenant|
        Administrator::CovenantSerializer.new(covenant)
      end
    end

    # has_one :legal_representative, serializer: LegalRepresentativeSerializer
    # forces to send address
    def legal_representative
      LegalRepresentativeSerializer.new(object.legal_representative)
    end
  end
end
