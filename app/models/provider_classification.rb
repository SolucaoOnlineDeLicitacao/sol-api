class ProviderClassification < ApplicationRecord
  versionable

  belongs_to :classification
  belongs_to :provider
end
