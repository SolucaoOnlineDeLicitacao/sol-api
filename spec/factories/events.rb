FactoryBot.define do
  factory :event do
    association :eventable, factory: :proposal
    association :creator, factory: :user
    data { {} }
    type ""
  end
end
