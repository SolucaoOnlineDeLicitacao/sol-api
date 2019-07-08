FactoryBot.define do
  factory :event_bidding_reproved, parent: :event, class: Events::BiddingReproved do
    from 'waiting'
    to 'draft'
    comment 'Licitação com dados errados!'
    type 'Events::BiddingReproved'

    association :eventable, factory: :bidding
    association :creator, factory: :user
  end
end
