class LotProposalImport < ApplicationRecord
  include Importable

  belongs_to :lot
end
