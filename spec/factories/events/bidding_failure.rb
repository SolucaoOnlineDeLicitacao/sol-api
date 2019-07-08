FactoryBot.define do
  factory :event_bidding_failure, parent: :event, class: Events::BiddingFailure do
    from 'waiting'
    to 'failure'
    comment 'Licitacao falha'
    type 'Events::BiddingFailure'

    association :eventable, factory: :bidding
    association :creator, factory: :user
  end
end
