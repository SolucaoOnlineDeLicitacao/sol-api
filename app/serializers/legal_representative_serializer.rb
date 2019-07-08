class LegalRepresentativeSerializer < ActiveModel::Serializer

  attributes :id, :name, :nationality, :civil_state, :rg, :cpf, :valid_until

  has_one :address

  def valid_until
    return 'N.I' unless object.valid_until
    I18n.l(object.valid_until)
  end
end
