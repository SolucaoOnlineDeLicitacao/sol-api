require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::Xls, type: :service do
  let(:import) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:spreadsheet) { Spreadsheet }
  let(:open_method) { :open }

  include_examples 'services/concerns/upload_base', 'xls'
end
