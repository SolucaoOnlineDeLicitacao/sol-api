#
# Custom class for PaperTrail::Version
#
class Version < PaperTrail::Version
  # using a custom table
  self.table_name = :versions
  self.sequence_name = :versions_id_seq

  # extra associations
  belongs_to :owner, polymorphic: true, optional: true

  delegate :name, to: :owner, prefix: true, allow_nil: true

  scope :with_owner, -> { where.not(owner_id: nil) }
end
