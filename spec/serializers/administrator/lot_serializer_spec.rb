require 'rails_helper'

RSpec.describe Administrator::LotSerializer, type: :serializer do
  it_behaves_like 'a lot_serializer'
end
