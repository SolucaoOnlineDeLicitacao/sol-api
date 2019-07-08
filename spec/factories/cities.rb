FactoryBot.define do
  factory :city do
    sequence(:code) { |n| n }
    sequence(:name) { |n| "Cidade #{n}" }
    state
  end
end
