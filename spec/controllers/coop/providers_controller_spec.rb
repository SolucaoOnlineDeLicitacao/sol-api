require 'rails_helper'

RSpec.describe Coop::ProvidersController, type: :controller do
  let(:serializer) { Coop::ProviderSerializer }
  let(:user) { create :user }
  let!(:provider) { create(:individual) }
  let!(:suppliers) do
    [
      create_list(:supplier, 2, provider: provider),
      create(:supplier, provider: provider)
    ].flatten
  end
  let!(:providers) { Individual.where(id: suppliers.pluck(:provider_id)) }
  let!(:provider_without_user) { create(:provider) }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Provider }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name',
          sort_direction: 'desc' }
      end
      let(:exposed) { Provider.joins(:suppliers) }

      before do
        allow(exposed).to receive(:search) { exposed }
        allow(exposed).to receive(:sorted) { exposed }
        allow(exposed).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:providers) { exposed }

        get_index
      end

      it { expect(exposed).to have_received(:search).with('search') }
      it { expect(exposed).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { providers.map{ |provider| format_json(serializer, provider) } }

      context 'when it does not have the classification parameters' do
        before { get_index }

        it { expect(response).to have_http_status :ok }
        it { expect(controller.providers.map(&:id)).to eq providers.map(&:id) }
        it { expect(json).to eq expected_json }
      end

      context 'when it has the classification parameters' do
        let(:params) { { classification_ids: classification_ids } }

        before { get_index }

        context 'and 2 classification ids are sent' do
          let(:classification_ids) do
            providers.map(&:classification_ids).flatten
          end

          it { expect(response).to have_http_status :ok }
          it { expect(controller.providers.map(&:id)).to eq providers.map(&:id) }
          it { expect(json).to eq expected_json }
        end

        context 'and 1 classification id is sent' do
          let(:expected_json) { format_json(serializer, provider) }
          let(:classification_ids) { provider.classifications.ids }

          it { expect(response).to have_http_status :ok }
          it { expect(controller.providers.first).to eq provider }
          it { expect(json.first).to eq expected_json }
        end

        context 'and classification params are empty' do
          let(:classification_ids) { [] }

          it { expect(response).to have_http_status :ok }
          it { expect(controller.providers.map(&:id)).to eq providers.map(&:id) }
          it { expect(json).to eq expected_json }
        end
      end
    end
  end

  describe '#show' do
    let(:params) { { id: provider } }
    let(:json) { JSON.parse(response.body) }
    let(:expected_json) { format_json(serializer, provider) }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    it { expect(response).to have_http_status :ok }
    it { expect(controller.provider).to eq provider }
    it { expect(json).to eq expected_json }
  end
end
