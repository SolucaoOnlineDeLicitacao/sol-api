FactoryBot.define do
  factory :group_item do
    group
    item
    quantity { rand(10..20) }
    available_quantity { rand(10..20) }
    estimated_cost { rand(10..200) }
  end
end
