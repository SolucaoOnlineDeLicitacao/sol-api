class Events::BiddingFailure < Event
  data_attr :from, :to, :comment

  validates :from, inclusion: { in: Bidding.statuses.keys }
  validates :to, inclusion: { in: ['failure'] }

  validates :comment, presence: true
end
