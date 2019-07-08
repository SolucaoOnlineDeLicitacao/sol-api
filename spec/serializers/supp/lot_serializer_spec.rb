require 'rails_helper'

RSpec.describe Supp::LotSerializer, type: :serializer do
  it_behaves_like 'a lot_serializer'
end
