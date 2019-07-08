require 'rails_helper'

RSpec.describe Administrator::PasswordsController, type: :controller do
  let(:resource) { create(:admin) }

  it_behaves_like 'a password operations to', 'admin'
end
