class ItemSerializer < ActiveModel::Serializer
  attributes :id, :code, :title, :description, :unit_id, :unit_name, :owner_name,
              :classification_id, :children_classification_id, :classification_name

  def classification_id
    if children?
      object.classification.classification_id
    else
      object.classification_id
    end
  end

  def children_classification_id
    if children?
      object.classification_id
    end
  end

  private

  def children?
    object.classification.classification.present? &&
    object.classification.classification.classification.present?
  end
end
