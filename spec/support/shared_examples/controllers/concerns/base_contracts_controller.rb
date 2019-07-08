RSpec.shared_examples "controllers/concerns/base_contracts_controller" do
  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { } }

    subject(:get_index) { get :index, params: params, xhr: true }

    describe 'helpers' do
      let!(:params) { { search: 'search', page: 2 } }
      let(:exposed_contracts) { Contract.all }

      before do
        allow(exposed_contracts).to receive(:search) { exposed_contracts }
        allow(exposed_contracts).to receive(:sorted) { exposed_contracts }
        allow(exposed_contracts).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:contracts) { exposed_contracts }

        get_index
      end

      it { expect(exposed_contracts).to have_received(:search).with('search') }
      it { expect(exposed_contracts).to have_received(:sorted).with('contracts.id', :desc) }
      it { expect(exposed_contracts).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      let!(:another_contract) { create(:contract) }

      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.contracts).to match_array contracts }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { contracts.map { |contract| format_json(serializer, contract) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { id: contract } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.contract).to eq contract }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, contract) }

      it { expect(json).to eq expected_json }
    end
  end
end
