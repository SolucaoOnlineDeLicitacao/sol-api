FactoryBot.define do
  factory :company, parent: :provider, class: Company do
    sequence(:document) { |n| "36.325.455/0001-#{n}" }
  end
end
