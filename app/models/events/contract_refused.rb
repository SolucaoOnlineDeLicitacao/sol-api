class Events::ContractRefused < Event
  data_attr :from, :to, :comment

  validates :to, inclusion: { in: %w(refused) }

  validates :comment, presence: true
end
