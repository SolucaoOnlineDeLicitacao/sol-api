FactoryBot.define do
  factory :individual, parent: :provider, class: Individual do
    sequence(:document) { |n| "12.345.#{n}-00" }
  end
end
