
FactoryBot.define do
  factory :address do
    association :addressable, factory: :cooperative
    latitude { Geo::Latitude.rand }
    longitude { Geo::Longitude.rand }
    address "Rua Carlos Gomes"
    number "123A"
    neighborhood "Centro"
    cep { ZipCode.generate }
    complement "AP 34"
    reference_point "Próximo ao Swiss Park"
    city

    trait :provider_address do
      association :addressable, factory: :provider
    end

    trait :legal_representative_address do
      association :addressable, factory: :legal_representative
    end

  end
end
