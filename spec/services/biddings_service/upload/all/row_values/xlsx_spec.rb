require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::RowValues::Xlsx, type: :service do
  include_examples 'services/concerns/upload_row_values'
end
