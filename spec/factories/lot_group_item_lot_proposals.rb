FactoryBot.define do
  factory :lot_group_item_lot_proposal do
    lot_group_item
    lot_proposal
    price { rand(1..100) }

    trait :invalid do
      lot_group_item nil
      lot_proposal nil
      supplier nil
      price nil
    end
  end
end
