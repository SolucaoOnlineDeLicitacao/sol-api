FactoryBot.define do
  factory :event_invite_reproved, parent: :event, class: Events::InviteReproved do
    from 'pending'
    to 'reproved'
    comment 'CNPJ não é valido'
    type 'Events::InviteReproved'

    association :eventable, factory: :invite
    association :creator, factory: :user
  end
end
