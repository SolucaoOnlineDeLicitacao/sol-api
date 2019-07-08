class Events::CancelProposalAccepted < Event
  data_attr :from, :to, :comment

  validates :to, :from, inclusion: { in: ::Proposal.statuses.keys }

  validates :comment, presence: true
end
