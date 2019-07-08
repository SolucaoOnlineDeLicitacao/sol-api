class SupplierSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :cpf, :phone, :provider_id, :provider_name
end
