FactoryBot.define do
  factory :state do
    sequence(:code) { |n| n }
    sequence(:uf) { |n| "E#{n}" }
    sequence(:name) { |n| "Estado #{n}" }
  end
end
