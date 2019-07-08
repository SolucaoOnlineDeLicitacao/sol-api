FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@example.com" }
    sequence(:name)  { |n| "User #{n}" }

    password { "secret-#{rand(5000)}" }
    cpf { CPF.generate }
    phone "(11) 91234-5678"
    avatar Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/myfiles/avatar.jpg')))

    cooperative
    role
  end
end
