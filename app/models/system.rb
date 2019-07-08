class System < ApplicationRecord
  has_one :contract, as: :refused_by
end
