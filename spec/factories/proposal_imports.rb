FactoryBot.define do
  factory :proposal_import do
    provider
    bidding
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/myfiles/proposal_upload_1_1.xls")) }
    error_message nil
    error_backtrace nil
    status :waiting
    file_type :xls

    trait :with_xlsx do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/myfiles/proposal_upload_1_1.xlsx")) }
      file_type :xlsx
    end
  end
end
