require 'rails_helper'

RSpec.describe Administrator::ProvidersController, type: :controller do
  let(:serializer) { Administrator::ProviderSerializer }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:providers) { create_list(:provider, 2, type: 'Provider') }
    let(:provider) { providers.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Provider }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_providers) { Provider.all }

      before do
        allow(exposed_providers).to receive(:search) { exposed_providers }
        allow(exposed_providers).to receive(:sorted) { exposed_providers }
        allow(exposed_providers).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:providers) { exposed_providers }

        get_index
      end

      it { expect(exposed_providers).to have_received(:search).with('search') }
      it { expect(exposed_providers).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_providers).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.providers).to eq providers }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { providers.map { |provider| format_json(serializer, provider) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:provider) { create(:provider, type: 'Provider') }
    let(:params) { { id: provider } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.provider).to eq provider }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, provider) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:provider) { build(:provider, type: 'Provider') }
    let(:classification) { create(:classification) }
    let(:address) { build(:address) }
    let(:legal_representative) { build(:legal_representative) }
    let(:params) do
      {
        provider: provider.attributes.merge(
          address_attributes: address.attributes,
          legal_representative_attributes: legal_representative.attributes,
          provider_classifications_attributes: {
            id: nil, classification_id: classification.id
          }
        )
      }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_create', 'provider'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.provider).to be_instance_of Provider }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.provider).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['provider']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.provider).to receive(:save) { false }
          allow(controller.provider).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    describe 'with classifications' do
      let!(:provider) { create(:provider, :provider_classifications, type: 'Provider') }
      let(:params) do
        {
          provider: {
            document: provider.document,
            name: 'Provider 123',
            type: 'Provider',
            provider_classifications_attributes:{
              '0': { '_destroy': false, classification_id: provider.classifications[0].id },
              '1': { '_destroy': false, classification_id: provider.classifications[1].id },
              '2': { '_destroy': true, classification_id: provider.classifications[2].id }
            }
          }
        }
      end

      subject(:post_create) { post :create, params: params, xhr: true }

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          before do
            post_create
          end
          let(:provider_saved) { Provider.find(json['provider']['id']) }

          it { expect(response).to have_http_status :created }
          it { expect(json['provider']).to be_present }
          it { expect(provider_saved.classifications).to be_present }
          it { expect(provider_saved.classifications.size).to eq 2 }
          it { expect(provider_saved.classifications.size).to_not eq 3 }
        end
      end
    end
  end

  describe '#update' do
    let!(:provider) { create(:provider, type: 'Provider') }
    let(:new_name) { 'Updated Provider' }
    let(:params) { { id: provider, provider: { name: new_name } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'provider'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.provider.id).to eq provider.id }
      it { expect(controller.provider.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.provider).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['provider']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.provider).to receive(:save) { false }
          allow(controller.provider).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    describe 'with classifications' do
      let!(:provider) { create(:provider, :provider_classifications, type: 'Provider', skip_classification: true) }
      let(:params) do
        {
          id: provider,
          provider: {
            document: provider.document,
            name: 'Provider 122',
            type: 'Provider',
            provider_classifications_attributes: {
              '0': { '_destroy': false, classification_id: provider.classifications[0].id },
              '1': { '_destroy': false, classification_id: provider.classifications[1].id },
              '2': { '_destroy': true, classification_id: provider.classifications[2].id }
            }
          }
        }
      end

      subject(:post_update) { patch :update, params: params, xhr: true }

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          before { post_update }

          let(:provider_saved) { Provider.find(json['provider']['id']) }

          it { expect(response).to have_http_status :ok }
          it { expect(provider_saved.name).to_not eq provider.name }
          it { expect(provider_saved.classifications.size).to eq 5 }
        end
      end
    end
  end

  describe '#destroy' do
    let!(:provider) { create(:provider, type: 'Provider') }
    let(:params) { { id: provider } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'provider'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.provider).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.provider).to receive(:destroy) { false }
          allow(controller.provider).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  context 'when changing provider access' do
    let(:provider) { create(:provider, type: 'Provider') }
    let(:event) do
      create(
        :event_provider_access,
        eventable: provider,
        creator: user,
        blocked: blocked
      )
    end
    let(:service_response) { double('call', call: call_response, event: event) }
    let(:comment) { 'a comment' }
    let(:call_response) { event.update!(comment: comment) }
    let(:params) { { provider_id: provider.id, comment: comment } }

    describe '#block' do
      let(:blocked) { 1 }

      before do
        allow(ProvidersService::Block).to receive(:new).
          with(creator: user, provider: provider, comment: comment) { service_response }
      end

      subject(:post_block) { post :block, params: params, xhr: true }

      it_behaves_like 'an admin authorization to', 'user', 'write'

      it_behaves_like 'a version of', 'post_block', 'provider.event_provider_accesses'

      describe 'exposes' do
        before { post_block }

        it { expect(controller.provider).to eq provider }
      end

      describe 'JSON' do
        before { post_block }

        context 'when blocked' do
          it { expect(response).to have_http_status :ok }
        end

        context 'when not blocked' do
          let(:call_response) { false }

          it { expect(response).to have_http_status :unprocessable_entity }
        end
      end
    end

    describe '#unblock' do
      let(:blocked) { 0 }

      before do
        allow(ProvidersService::Unblock).to receive(:new).
          with(creator: user, provider: provider, comment: comment) { service_response }
      end

      subject(:post_unblock) { post :unblock, params: params, xhr: true }

      it_behaves_like 'an admin authorization to', 'user', 'write'

      it_behaves_like 'a version of', 'post_unblock', 'provider.event_provider_accesses'

      describe 'exposes' do
        before { post_unblock }

        it { expect(controller.provider).to eq provider }
      end

      describe 'JSON' do
        before { post_unblock }

        context 'when blocked' do
          it { expect(response).to have_http_status :ok }
        end

        context 'when not blocked' do
          let(:call_response) { false }

          it { expect(response).to have_http_status :unprocessable_entity }
        end
      end
    end
  end
end
