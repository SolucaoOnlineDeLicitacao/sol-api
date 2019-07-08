class Events::BiddingCancellationRequest < Event
  data_attr :from, :to, :comment, :comment_response, :status

  STATUSES = ['approved', 'reproved'].freeze

  validates :to, :from, inclusion: { in: Bidding.statuses.keys }
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  validates :comment, presence: true
  validates :comment_response, presence: true, on: :update

  def self.changing_to(status)
    # flexibilizing table name
    # @see https://github.com/rails/arel/issues/288#issuecomment-64015191
    #
    # where("data->>'to' = :status", status: status)
    arel_data_to = Arel::Nodes::InfixOperation.new('->>', arel_table[:data], Arel::Nodes.build_quoted('to'))
    where arel_data_to.eq(status)
  end

end
