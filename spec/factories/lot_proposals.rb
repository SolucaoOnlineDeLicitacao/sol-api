FactoryBot.define do
  factory :lot_proposal do
    lot
    proposal
    supplier
    price_total { rand(3500..4500) }
    delivery_price 0

    transient do
      build_lot_group_item_lot_proposal { true }
    end

    after :build do |object, eval|
      if eval.build_lot_group_item_lot_proposal
        resource = build(:lot_group_item_lot_proposal, lot_proposal: object,
                    lot_group_item: object.lot.lot_group_items.first)

        object.lot_group_item_lot_proposals << resource
      end
    end

    trait :invalid do
      lot nil
      proposal nil
      supplier
    end
  end
end
