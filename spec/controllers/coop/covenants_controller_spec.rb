require 'rails_helper'

RSpec.describe Coop::CovenantsController, type: :controller do
  let(:serializer) { Administrator::CovenantSerializer }
  let!(:covenants) { create_list(:covenant, 2) }
  let(:covenant) { covenants.first }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.current_cooperative.covenants }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_covenants) { cooperative.covenants }

      before do
        allow(exposed_covenants).to receive(:search) { exposed_covenants }
        allow(exposed_covenants).to receive(:sorted) { exposed_covenants }
        allow(controller).to receive(:covenants) { exposed_covenants }

        get_index
      end

      it { expect(exposed_covenants).to have_received(:sorted).with('name', 'desc') }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.covenants).to eq cooperative.covenants }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { cooperative.covenants.map { |covenant| format_json(serializer, covenant) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { id: covenant } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.covenant).to eq covenant }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, covenant) }

      it { expect(json).to eq expected_json }
    end
  end
end
