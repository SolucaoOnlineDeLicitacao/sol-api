require 'rails_helper'

RSpec.describe Administrator::CooperativesController, type: :controller do
  let(:serializer) { Administrator::CooperativeSerializer }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:cooperatives) { create_list(:cooperative, 2) }
    let(:cooperative) { cooperatives.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Cooperative }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_cooperatives) {  Cooperative.all }

      before do
        allow(exposed_cooperatives).to receive(:search) { exposed_cooperatives }
        allow(exposed_cooperatives).to receive(:sorted) { exposed_cooperatives }
        allow(exposed_cooperatives).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:cooperatives) { exposed_cooperatives }

        get_index
      end

      it { expect(exposed_cooperatives).to have_received(:search).with('search') }
      it { expect(exposed_cooperatives).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_cooperatives).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.cooperatives).to eq cooperatives }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { cooperatives.map { |coop| format_json(serializer, coop) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:cooperative) { create(:cooperative) }
    let(:params) { { id: cooperative } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.cooperative).to eq cooperative }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, cooperative) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:cooperative) { build(:cooperative) }
    let(:address) { build(:address) }
    let(:legal_representative) { build(:legal_representative) }
    let(:params) do
      {
        cooperative: cooperative.attributes.merge(
          address_attributes: address.attributes,
          legal_representative_attributes: legal_representative.attributes
        )
      }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_create', 'cooperative'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.cooperative).to be_instance_of Cooperative }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.cooperative).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['cooperative']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.cooperative).to receive(:save) { false }
          allow(controller.cooperative).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:cooperative) { create(:cooperative) }
    let(:new_name) { 'Updated Cooperative' }
    let(:params) { { id: cooperative, cooperative: { name: new_name } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_update', 'cooperative'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.cooperative.id).to eq cooperative.id }
      it { expect(controller.cooperative.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.cooperative).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['cooperative']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.cooperative).to receive(:save) { false }
          allow(controller.cooperative).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:cooperative) { create(:cooperative) }
    let(:params) { { id: cooperative } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'delete_destroy', 'cooperative'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.cooperative).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.cooperative).to receive(:destroy) { false }
          allow(controller.cooperative).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
