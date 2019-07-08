class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :cpf, :phone,
              :role_title, :role_id, :cooperative_id, :cooperative_name
end
