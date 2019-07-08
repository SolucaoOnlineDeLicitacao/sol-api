FactoryBot.define do
  factory :event_contract_refused, parent: :event, class: Events::ContractRefused do
    from 'waiting'
    to 'refused'
    comment 'contrato com dados errados!'
    type 'Events::ContractRefused'

    association :eventable, factory: :bidding
    association :creator, factory: :user
  end
end
