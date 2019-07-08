require 'rails_helper'

RSpec.describe Administrator::CovenantsController, type: :controller do
  let(:serializer) { Administrator::CovenantSerializer }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:covenants) { create_list(:covenant, 2) }
    let(:covenant) { covenants.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Covenant }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_covenants) { Covenant.all }

      before do
        allow(exposed_covenants).to receive(:search) { exposed_covenants }
        allow(exposed_covenants).to receive(:sorted) { exposed_covenants }
        allow(exposed_covenants).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:covenants) { exposed_covenants }

        get_index
      end

      it { expect(exposed_covenants).to have_received(:search).with('search') }
      it { expect(exposed_covenants).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_covenants).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.covenants).to eq covenants }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { covenants.map { |covenant| format_json(serializer, covenant) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:covenant) { create(:covenant) }
    let(:params) { { id: covenant } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

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

  describe '#create' do
    let(:covenant) { build(:covenant) }
    let(:params) { { covenant: covenant.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_create', 'covenant'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.covenant).to be_instance_of Covenant }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.covenant).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['covenant']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.covenant).to receive(:save) { false }
          allow(controller.covenant).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:covenant) { create(:covenant) }
    let(:new_name) { 'Updated Covenant' }
    let(:params) { { id: covenant, covenant: { name: new_name } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_update', 'covenant'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.covenant.id).to eq covenant.id }
      it { expect(controller.covenant.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.covenant).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['covenant']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.covenant).to receive(:save) { false }
          allow(controller.covenant).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:covenant) { create(:covenant) }
    let(:params) { { id: covenant } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'delete_destroy', 'covenant'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.covenant).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.covenant).to receive(:destroy) { false }
          allow(controller.covenant).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
