require 'rails_helper'

RSpec.describe Supp::Biddings::Invites::OpenController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }

  let(:approved_invite) do
    create(:invite, provider: provider, status: :approved)
  end
  let!(:biddings) do
    create_list(:bidding, 2, covenant: covenant, modality: :open_invite,
                             invites: [approved_invite])
  end
  let(:bidding) { biddings.first }

  before { oauth_token_sign_in user }

  describe '#create' do
    let(:params) { { bidding_id: bidding.id } }

    describe 'exposes' do
      it { expect(controller.invite).to be_a_new Invite }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'invite'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          post_create
        end

        let(:invite) { Invite.find json['invite']['id'] }

        it { expect(response).to have_http_status :created }
        it { expect(json['invite']).to be_present }
        it { expect(invite.provider).to be_present }
        it { expect(invite.bidding).to be_present }
        it { expect(invite.approved?).to be_truthy }
      end

      context 'when not created' do
        before do
          allow(controller.invite).to receive(:save) { false }
          allow(controller.invite).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
