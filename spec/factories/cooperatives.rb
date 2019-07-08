FactoryBot.define do
  factory :cooperative do
    sequence(:name) { |n| "Associação #{n}" }
    cnpj { CNPJ.generate }

    after :build do |object|
      object.address ||= build(:address, addressable: object)
      object.legal_representative ||= build(:legal_representative, representable: object)
      object.users ||= [build(:user, cooperative: object)]
    end
  end
end
