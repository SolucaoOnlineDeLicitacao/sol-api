class ProviderClassificationSerializer < ActiveModel::Serializer

  attributes :id, :name, :classification_id, :_destroy

  def name
    object.classification.text
  end
end
