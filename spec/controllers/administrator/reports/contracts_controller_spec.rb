require 'rails_helper'

RSpec.describe Administrator::Reports::ContractsController, type: :controller do
  let(:admin_user) { create :admin }

  before { oauth_token_sign_in admin_user }

  describe "#index" do

    subject(:get_index) { get :index, xhr: true }
    
    before do
      allow(ReportsService::Contract).to receive(:call).with(no_args) { true }
      get_index
    end
    
    it { expect(ReportsService::Contract).to have_received(:call).with(no_args) }
  end

end
