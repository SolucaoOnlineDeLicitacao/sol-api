FactoryBot.define do
  factory :group_item do
    group
    item
    quantity { rand(10.4..20.9) }
    available_quantity { rand(10.4..20.9) }
    estimated_cost { rand(10..200) }
  end
end
