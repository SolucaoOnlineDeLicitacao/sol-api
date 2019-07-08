require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::RowDeliveryPrice::Xls, type: :service do
  let(:import) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:book) { Spreadsheet.open(import.file.url) }
  let(:sheet) { book.worksheet(1) }

  include_examples 'services/concerns/upload_row_delivery_price', 'xls'
end
