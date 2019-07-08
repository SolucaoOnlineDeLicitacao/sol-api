FactoryBot.define do
  factory :lot_proposal_import do
    provider
    bidding
    lot
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/myfiles/proposal_upload_1_1.xls")) }
    file_type :xls
    error_message nil
    error_backtrace nil
    status :waiting
  end
end
