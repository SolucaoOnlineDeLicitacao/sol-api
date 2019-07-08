FactoryBot.define do
  factory :item do
    sequence(:code) { |code| code }
    sequence(:title) { |t| "Parafuso #{t}" }
    sequence(:description) { |t| "Parafuso de 5mm x 35mm #{t} de ferro 1045 temperado" }
    association :owner, factory: :admin
    classification
    unit
  end
end
