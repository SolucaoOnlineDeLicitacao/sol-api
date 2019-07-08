FactoryBot.define do
  factory :group do
    covenant
    sequence(:name) { |n| "Obra #{n}" }

    transient do
      build_group_itens { true }
    end

    after :build do |object, eval|
      object.group_items << build(:group_item, group: object) if eval.build_group_itens
    end

    trait :skip_validation do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
