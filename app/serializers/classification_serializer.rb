class ClassificationSerializer < ActiveModel::Serializer

  attributes :id, :name, :code

  has_many :providers, serializer: Administrator::ProviderSerializer
end
