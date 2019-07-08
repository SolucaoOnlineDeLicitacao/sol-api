FactoryBot.define do
  factory :contract do
    proposal
    user
    user_signed_at { DateTime.current }
    deadline 60

    trait :full_signed_at do
      supplier_signed_at { DateTime.current }
      refused_by_at { DateTime.current }
      association :refused_by, factory: :supplier
    end
  end
end
