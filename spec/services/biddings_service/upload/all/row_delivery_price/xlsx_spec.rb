require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::RowDeliveryPrice::Xlsx, type: :service do
  let(:import) { create(:proposal_import, :with_xlsx, bidding: bidding, provider: provider) }
  let(:book) { RubyXL::Parser.parse(import.file.url) }
  let(:sheet) { book[1] }

  include_examples 'services/concerns/upload_row_delivery_price', 'xlsx'
end
