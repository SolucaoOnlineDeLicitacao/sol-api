FactoryBot.define do
  factory :unit do
    sequence(:name) { |t| "Unidade #{t}" }
  end
end
