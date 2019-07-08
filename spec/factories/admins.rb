FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin-#{n}@example.com" }
    sequence(:name)  { |n| "Admin #{n}" }

    password { "secret-#{rand(5000)}" }

    role { :general }
  end
end
