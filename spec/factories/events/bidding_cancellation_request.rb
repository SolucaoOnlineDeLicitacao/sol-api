FactoryBot.define do
  factory :event_bidding_cancellation_request, parent: :event, class: Events::BiddingCancellationRequest do
    from 'draft'
    to 'waiting'
    comment 'CNPJ não é valido'
    comment_response nil
    status ''
    type 'Events::BiddingCancellationRequest'

    association :eventable, factory: :proposal
    association :creator, factory: :user
  end
end
