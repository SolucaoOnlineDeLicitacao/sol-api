FactoryBot.define do
  factory :covenant do
    sequence(:name) { |n| "Convênio #{n}" }
    sequence(:number) { |n| "0001/0#{n}" }
    status :waiting
    signature_date { Date.yesterday }
    validity_date { Date.today + 60.days }
    estimated_cost { rand(2_000_000..5_000_000) }
    cooperative
    admin
    city

    transient do
      group { true }
    end

    after :build do |object, evaluator|
      object.groups << build(:group, covenant: object) if evaluator.group
    end

    trait :invalid do
      number nil
      cooperative nil
      admin nil
    end
  end
end
