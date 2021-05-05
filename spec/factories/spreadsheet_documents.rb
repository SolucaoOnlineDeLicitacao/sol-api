FactoryBot.define do
  factory :spreadsheet_document do
    file Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/myfiles/proposal_upload_1_1.xls')))
  end
end
