FactoryBot.define do
  factory :lot_group_item do
    lot
    group_item
    quantity { rand(1.0..group_item.quantity-1) }

    trait :invalid do
      lot nil
      group_item nil
      quantity 0
    end
  end
end
