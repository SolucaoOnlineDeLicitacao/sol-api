require 'rails_helper'

RSpec.describe Supp::SuppliersController, type: :controller do
  let(:resource) { create :supplier }

  it_behaves_like "controllers/concerns/base_profiles_controller", :supplier
  it_behaves_like "a supplier authorization to", 'write'
end
