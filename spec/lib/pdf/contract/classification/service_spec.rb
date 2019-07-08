require 'rails_helper'

RSpec.describe Pdf::Contract::Classification::Service do
  include_examples 'lib/contract/classifications', 'contract_service.html'
end
