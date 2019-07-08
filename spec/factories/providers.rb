FactoryBot.define do
  factory :provider do
    sequence(:document) { |n| "12.345.#{n}-00" }
    sequence(:name) { |n| "Carls Max #{n}" }
    type "Individual" # STI type

    transient do
      skip_classification { false }
    end

    after :build do |object, eval|
      object.address ||= build(:address, addressable: object)
      object.legal_representative ||= build(:legal_representative, representable: object)
      object.classifications << build(:classification) unless object.classifications.present? || eval.skip_classification
    end

    trait :skip_validation do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :provider_classifications do
      after :build do |object|
        object.classifications << create_list(:classification, 3)
      end
    end
  end
end
