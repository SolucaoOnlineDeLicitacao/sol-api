require 'rails_helper'

RSpec.describe Pdf::Contract::Classification::Work do
  include_examples 'lib/contract/classifications', 'contract_work.html'
end
