class Events::ProposalStatusChange < Event
  data_attr :from, :to, :comment

  validates :to, :from, inclusion: { in: Proposal.statuses.keys }

  validates :comment, presence: true, if: :needs_comment?

  def self.changing_to(status)
    # flexibilizing table name
    # @see https://github.com/rails/arel/issues/288#issuecomment-64015191
    #
    # where("data->>'to' = :status", status: status)
    arel_data_to = Arel::Nodes::InfixOperation.new('->>', arel_table[:data], Arel::Nodes.build_quoted('to'))
    where arel_data_to.eq(status)
  end

  private

  def needs_comment?
    to == 'coop_refused'
  end
end
