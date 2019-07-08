class Events::BiddingReproved < Event
  data_attr :from, :to, :comment

  validates :to, :from, inclusion: { in: %w(draft waiting) }

  validates :comment, presence: true
end
