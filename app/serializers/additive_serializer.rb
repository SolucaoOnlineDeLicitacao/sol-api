class AdditiveSerializer < ActiveModel::Serializer

  attributes :id, :from, :to

  def from
    return unless object.from
    I18n.l(object.from)
  end

  def to
    return unless object.to
    I18n.l(object.to)
  end
end
