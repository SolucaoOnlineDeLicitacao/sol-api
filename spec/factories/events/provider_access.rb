FactoryBot.define do
  factory :event_provider_access, parent: :event, class: Events::ProviderAccess do
    blocked 0
    comment 'a comment'
    type 'Events::ProviderAccess'

    association :eventable, factory: :provider
    association :creator, factory: :user
  end
end
