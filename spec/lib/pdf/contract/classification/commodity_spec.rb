require 'rails_helper'

RSpec.describe Pdf::Contract::Classification::Commodity do
  include_examples 'lib/contract/classifications', 'contract_commodity.html'
end
