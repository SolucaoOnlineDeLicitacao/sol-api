require 'rails_helper'

RSpec.describe Administrator::Biddings::ContractSerializer, type: :serializer do
  describe 'BaseContractsSerializer' do
    include_examples "serializers/concerns/base_contracts_serializer"
  end
end
