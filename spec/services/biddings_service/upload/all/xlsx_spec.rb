require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::Xlsx, type: :service do
  let(:import) do
    create(:proposal_import, :with_xlsx, bidding: bidding, provider: provider)
  end
  let(:spreadsheet) { RubyXL::Parser }
  let(:open_method) { :parse }

  include_examples 'services/concerns/upload_base', 'xlsx'
end
