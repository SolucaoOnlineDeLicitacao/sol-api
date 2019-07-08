require 'rails_helper'

RSpec.describe Coop::Biddings::FailuresController, type: :controller do

  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user) }

  let!(:bidding) { create(:bidding, covenant: covenant) }
  let!(:lot) { create(:lot, bidding: bidding) }

  let(:comment) { 'comment' }

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { bidding_id: bidding, comment: comment } }

    before { bidding.reload.lots.map(&:failure!); post_update }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding'

    describe 'JSON' do
      context 'when updated' do
        describe 'exposes' do
          it { expect(controller.bidding.id).to eq bidding.id }
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:json) { JSON.parse(response.body) }
        let(:comment) { '' }
        let(:json) { JSON.parse(response.body) }
        let(:error_event_key) { ['comment'] }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors'].keys).to eq error_event_key }
      end

    end
  end

end
