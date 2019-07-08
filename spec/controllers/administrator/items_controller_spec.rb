require 'rails_helper'

RSpec.describe Administrator::ItemsController, type: :controller do
  let(:serializer) { ItemSerializer }
  let(:user) { create :admin }
  let!(:items) { create_list(:item, 2) }
  let(:item) { items.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Item }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:exposed_items) { Item.all }

      before do
        allow(exposed_items).to receive(:search) { exposed_items }
        allow(exposed_items).to receive(:sorted) { exposed_items }
        allow(exposed_items).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:items) { exposed_items }

        get_index
      end

      it { expect(exposed_items).to have_received(:search).with('search') }
      it { expect(exposed_items).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_items).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.items).to eq items }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { items.map { |item| format_json(serializer, item) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { id: item } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.item).to eq item }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, item) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let!(:classification) { create(:classification) }

    let!(:item_attributes) do
      build(:item).attributes.merge!({ classification_id: classification.id })
    end

    let(:params) { { item: item_attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_create', 'item'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.item).to be_a Item }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.item).to receive(:save) { true }

          post_create
        end

        it { expect(controller.item.owner).to eq user }
        it { expect(response).to have_http_status :created }
        it { expect(json['item']).to be_present }
      end

      context 'when children_classification_id' do
        let!(:children_classification) { create(:classification) }

        before do
          params[:item].merge!({ children_classification_id: children_classification.id })

          post_create
        end

        it { expect(controller.item.classification).to eq children_classification }
      end

      context 'when not created' do
        before do
          allow(controller.item).to receive(:save) { false }
          allow(controller.item).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let(:new_title) { 'Updated Item' }
    let(:params) { { id: item, item: { title: new_title } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'post_update', 'item'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.item.id).to eq item.id }
      it { expect(controller.item.title).to eq new_title }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.item).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['item']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.item).to receive(:save) { false }
          allow(controller.item).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let(:params) { { id: item } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'delete'
    it_behaves_like 'an integration authorization to', 'user'

    it_behaves_like 'a version of', 'delete_destroy', 'item'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.item).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.item).to receive(:destroy) { false }
          allow(controller.item).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
