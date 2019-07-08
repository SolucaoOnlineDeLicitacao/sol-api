require 'rails_helper'

RSpec.describe Administrator::Reports::BiddingsController, type: :controller do
  let(:admin_user) { create :admin }

  before { oauth_token_sign_in admin_user }

  describe "#index" do

    subject(:get_index) { get :index, xhr: true }
    
    before do
      allow(ReportsService::Bidding).to receive(:call).with(no_args) { true }
      get_index
    end
    
    it { expect(ReportsService::Bidding).to have_received(:call).with(no_args) }
  end

end
