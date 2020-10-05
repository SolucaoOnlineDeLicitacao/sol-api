require 'rails_helper'

RSpec.describe Coop::UsersController, type: :controller do
  let(:resource) { create :user }

  it_behaves_like "controllers/concerns/base_profiles_controller", :user
  it_behaves_like "an user authorization to", 'write'
end
