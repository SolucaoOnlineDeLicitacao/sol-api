FactoryBot.define do
  factory :event_cancel_proposal_accepted, parent: :event, class: Events::CancelProposalAccepted do
    from 'sent'
    to 'refused'
    comment 'Proposta Aceita, negada pelo revisor'
    type 'Events::CancelProposalAccepted'

    association :eventable, factory: :proposal
    association :creator, factory: :user
  end
end
