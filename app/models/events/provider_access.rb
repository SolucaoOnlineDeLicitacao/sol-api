class Events::ProviderAccess < Event
  data_attr :blocked, :comment

  validates :blocked, inclusion: { in: [0, 1] }
  validates :comment, presence: true
end
