require 'rails_helper'

require './app/services/contracts_service/clone/base'

RSpec.describe ContractsService::Clone::Refused, type: :service do
  include_examples 'services/concerns/clone', contract_status: :refused
end
