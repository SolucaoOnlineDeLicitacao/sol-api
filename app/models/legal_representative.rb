class LegalRepresentative < ApplicationRecord
  versionable

  belongs_to :representable, polymorphic: true
  has_one :address, as: :addressable, dependent: :destroy

  enum civil_state: %i[single married divorced widower separated]

  validates :name,
            :nationality,
            :civil_state,
            :rg,
            :cpf,
            presence: true

  validates :cpf, cpf: true

  accepts_nested_attributes_for :address
end
