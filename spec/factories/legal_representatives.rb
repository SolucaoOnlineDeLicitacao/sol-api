FactoryBot.define do
  factory :legal_representative do
    association :representable, factory: :cooperative
    name "John Doe"
    nationality "Brasileiro"
    civil_state 1
    rg "12.345.678-90"
    cpf { CPF.generate }
    valid_until { Date.tomorrow }

    after :build do |object|
      object.address ||= build(:address, addressable: object)
    end

    trait :provider_representable do
      association :representable, factory: :provider
    end

    trait :expired do
      valid_until { Date.yesterday }
    end
  end
end
