require 'rails_helper'

RSpec.describe Administrator::SuppliersController, type: :controller do
  let(:serializer) { SupplierSerializer }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    let!(:suppliers) { create_list(:supplier, 2) }
    let(:supplier) { suppliers.first }
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Supplier }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'name', sort_direction: 'desc' }
      end

      let(:exposed_suppliers) { Supplier.all }

      before do
        allow(exposed_suppliers).to receive(:search) { exposed_suppliers }
        allow(exposed_suppliers).to receive(:sorted) { exposed_suppliers }
        allow(exposed_suppliers).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:suppliers) { exposed_suppliers }

        get_index
      end

      it { expect(exposed_suppliers).to have_received(:search).with('search') }
      it { expect(exposed_suppliers).to have_received(:sorted).with('name', 'desc') }
      it { expect(exposed_suppliers).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.suppliers).to eq suppliers }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { suppliers.map { |supplier| format_json(serializer, supplier) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let!(:supplier) { create(:supplier) }
    let(:params) { { id: supplier } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.supplier).to eq supplier }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, supplier) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:supplier) { build(:supplier) }
    let(:params) { { supplier: supplier.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_create', 'supplier'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.supplier).to be_instance_of Supplier }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.supplier).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['supplier']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.supplier).to receive(:save) { false }
          allow(controller.supplier).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let!(:supplier) { create(:supplier) }
    let(:new_email) { 'caiena@caiena.net' }
    let(:params) { { id: supplier, supplier: { email: new_email } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'supplier'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.supplier.id).to eq supplier.id }
      it { expect(controller.supplier.email).to eq new_email }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.supplier).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['supplier']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.supplier).to receive(:save) { false }
          allow(controller.supplier).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let!(:supplier) { create(:supplier) }
    let(:params) { { id: supplier } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'supplier'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.supplier).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.supplier).to receive(:destroy) { false }
          allow(controller.supplier).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
