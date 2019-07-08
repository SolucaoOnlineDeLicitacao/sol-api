require 'rails_helper'

RSpec.describe Coop::Biddings::Invites::ApprovesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:biddings) { create_list(:bidding, 2, :with_pending_invites, covenant: covenant) }
  let(:bidding) { biddings.first }
  let(:invite) { bidding.invites.last }

  let!(:providers) { create_list(:individual, 2) }
  let(:provider) { providers.first }

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) do
      {
        bidding_id: bidding.id,
        invite_id: invite.id,
      }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'invite'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.invite.approved?).to be_truthy }
    end

    describe 'JSON' do
      context 'when updated' do
        before do
          allow(invite).to receive(:save!) { true }

          allow(Notifications::Invites::Approved).to receive(:call).with(invite).and_call_original

          post_update
        end

        describe 'notification' do
          it { expect(Notifications::Invites::Approved).to have_received(:call).with(invite) }
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        before do
          allow(invite).to receive(:save!) { raise ActiveRecord::RecordInvalid }
          allow(controller).to receive(:invite) { invite }

          allow(Notifications::Invites::Approved).to receive(:call).with(invite).and_call_original

          post_update
        end

        describe 'notification' do
          it { expect(Notifications::Invites::Approved).not_to have_received(:call).with(invite) }
        end

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

end
