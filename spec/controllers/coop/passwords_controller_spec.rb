require 'rails_helper'

RSpec.describe Coop::PasswordsController, type: :controller do
  let(:resource) { create(:user) }

  it_behaves_like 'a password operations to', 'user'
end

