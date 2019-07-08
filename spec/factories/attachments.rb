FactoryBot.define do
  factory :attachment do
    file Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/myfiles/file.pdf')))
    association :attachable, factory: :provider
  end
end
