FactoryBot.define do
  factory :event_proposal_status_change, parent: :event, class: Events::ProposalStatusChange do
    from 'triage'
    to 'coop_refused'
    comment 'CNPJ não é valido'
    type 'Events::ProposalStatusChange'

    association :eventable, factory: :proposal
    association :creator, factory: :user
  end
end
