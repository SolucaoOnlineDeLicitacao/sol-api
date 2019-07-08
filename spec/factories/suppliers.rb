FactoryBot.define do
  factory :supplier do
    sequence(:email) { |n| "supplier-#{n}@example.com" }
    sequence(:name)  { |n| "Fornecedor #{n}" }

    password { "secret-#{rand(5000)}" }
    cpf { CPF.generate }
    phone "(11) 91234-5678"
    avatar Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/myfiles/avatar.jpg')))

    provider
  end
end
