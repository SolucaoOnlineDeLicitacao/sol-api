require 'rails_helper'

RSpec.describe Coop::GroupSerializer, type: :serializer do
  it_behaves_like 'a group_serializer'
end
