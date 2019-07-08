FactoryBot.define do
  factory :role do
    sequence(:title) { |s| "Cargo #{s}" }
  end
end
