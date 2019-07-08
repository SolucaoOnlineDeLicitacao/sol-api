require 'rails_helper'

RSpec.describe Supp::PasswordsController, type: :controller do
  let(:resource) { create(:supplier) }

  it_behaves_like 'a password operations to', 'supplier'
end
