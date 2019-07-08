class AdminSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :covenants

  def covenants
    object.covenants.select(:id, :number, :name)
  end
end
