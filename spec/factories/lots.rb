FactoryBot.define do
  factory :lot do
    bidding
    sequence(:name) { |n| "Lote #{n}" }
    address 'address'

    transient do
      build_lot_group_item { true }
      build_attachments { true }
    end

    after :build do |object, eval|
      object.lot_group_items << build(:lot_group_item, lot: object) if eval.build_lot_group_item
    end

    after :build do |object, eval|
      object.attachments << build(:attachment, attachable: object) if eval.build_attachments
    end

    trait :skip_validation do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :invalid do
      bidding nil
      name nil
    end
  end
end
