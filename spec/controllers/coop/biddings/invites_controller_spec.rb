require 'rails_helper'

RSpec.describe Coop::Biddings::InvitesController, type: :controller do
  let(:serializer) { Coop::InviteSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:biddings) do
    create_list(:bidding, 2, :with_invites, covenant: covenant, status: :ongoing)
  end
  let(:bidding) { biddings.first }
  let(:invites) { bidding.invites }
  let(:invite) { invites.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: invite.bidding, id: invite } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.invites).to eq invites }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { invites.map { |item| format_json(serializer, item, scope: user) } }

        it { expect(json).to eq expected_json }
      end
    end
  end
end
