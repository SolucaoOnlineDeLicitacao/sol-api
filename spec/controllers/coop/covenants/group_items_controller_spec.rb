require 'rails_helper'

RSpec.describe Coop::Covenants::GroupItemsController, type: :controller do
  let(:serializer) { Administrator::GroupItemSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let(:group_items) { covenant.group_items }
  let(:lot) { group_items.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { covenant_id: covenant } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { GroupItem }
    end

    describe 'helpers' do
      let!(:params) do
        { covenant_id: covenant, search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:exposed_group_items) { covenant.group_items }

      before do
        allow(exposed_group_items).to receive(:search) { exposed_group_items }
        allow(exposed_group_items).to receive(:sorted) { exposed_group_items }
        allow(exposed_group_items).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:group_items) { exposed_group_items }

        get_index
      end

      it { expect(exposed_group_items).to have_received(:search).with('search') }
      it { expect(exposed_group_items).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_group_items).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.group_items).to eq group_items }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { group_items.map { |group_item| format_json(serializer, group_item) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

end
