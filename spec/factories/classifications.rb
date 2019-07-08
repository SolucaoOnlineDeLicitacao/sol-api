FactoryBot.define do
  factory :classification do
    sequence(:name) { |s| "Obras #{s}" }
    sequence(:code) { |c| c }
    classification nil
  end
end
