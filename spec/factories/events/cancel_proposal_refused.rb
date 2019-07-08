FactoryBot.define do
  factory :event_cancel_proposal_refused, parent: :event, class: Events::CancelProposalRefused do
    from 'sent'
    to 'refused'
    comment 'Proposta Negada'
    type 'Events::CancelProposalRefused'

    association :eventable, factory: :proposal
    association :creator, factory: :user
  end
end
