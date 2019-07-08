class Events::InviteReproved < Event
  data_attr :from, :to, :comment

  validates :to, :from, inclusion: { in: Invite.statuses.keys }

  validates :comment, presence: true
end
