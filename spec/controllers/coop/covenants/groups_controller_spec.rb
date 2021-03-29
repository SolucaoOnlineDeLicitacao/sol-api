require 'rails_helper'

RSpec.describe Coop::Covenants::GroupsController, type: :controller do
  let(:serializer) { Coop::GroupSerializer }
  let(:covenant) { create(:covenant, group: false) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:groups) { create_list(:group, 2, covenant: covenant) }
  let(:group) { groups.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { covenant_id: covenant } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Group }
    end

    describe 'helpers' do
      let!(:params) do
        { covenant_id: covenant, search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_groups) { Group.all }

      before do
        allow(exposed_groups).to receive(:search) { exposed_groups }
        allow(exposed_groups).to receive(:sorted) { exposed_groups }
        allow(exposed_groups).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:groups) { exposed_groups }

        get_index
      end

      it { expect(exposed_groups).to have_received(:search).with('search') }
      it { expect(exposed_groups).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_groups).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.groups).to match_array groups }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { groups.map { |group| format_json(serializer, group) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { covenant_id: covenant, id: group } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.group).to eq group }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, group) }

      it { expect(json).to eq expected_json }
    end
  end
end
