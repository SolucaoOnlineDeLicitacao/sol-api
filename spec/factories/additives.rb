FactoryBot.define do
  factory :additive do
    association :bidding, factory: :bidding, closing_date: Date.current

    from { Date.current }
    to { (bidding&.closing_date || Date.current) + 5.days }

    trait :with_retroactive_date do
      to { (bidding&.closing_date || Date.current) - 1.day }
    end
  end
end
