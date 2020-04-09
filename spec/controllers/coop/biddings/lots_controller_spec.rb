require 'rails_helper'

RSpec.describe Coop::Biddings::LotsController, type: :controller do
  let(:serializer) { Coop::LotSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant) }
  let(:bidding) { biddings.first }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }

  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/myfiles/file.pdf')) }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: lot.bidding, id: lot } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.bidding.lots }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: lot.bidding, id: lot, search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:exposed_lots) { lots }

      before do
        allow(exposed_lots).to receive(:search) { exposed_lots }
        allow(exposed_lots).to receive(:sorted) { exposed_lots }
        allow(exposed_lots).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:lots) { exposed_lots }

        get_index
      end

      it { expect(exposed_lots).to have_received(:search).with('search') }
      it { expect(exposed_lots).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_lots).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.lots).to eq lots }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { lots.map { |lot| format_json(serializer, lot) } }

        it { expect(json).to eq expected_json }
      end
    end
  end


  describe '#show' do
    let(:params) { { bidding_id: lot.bidding, id: lot } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.lot).to eq lot }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, lot) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:lot_group_item) { build(:lot_group_item, lot: lot) }
    let(:lot_name) { 'Lote name 001' }
    let(:params) do
      {
        lot: lot.attributes.except('id').merge(
          'name': lot_name,
          'attachments_attributes': {
            '0': { '_destroy': false, lot_id: lot.id, file: file }
          },
          lot_group_items_attributes: [lot_group_item.attributes]
        ),
        bidding_id: lot.bidding
      }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'lot'

    context 'with attachments' do
      describe 'exposes' do
        before { post_create }

        it { expect(controller.lot).to be_a Lot }
        it { expect(controller.lot.bidding).to eq bidding }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          let(:lot_saved) { Lot.find_by(name: lot_name) }

          before do
            allow(RecalculateQuantityService).
              to receive(:call!).with(covenant: lot.bidding.covenant) { true }
            post_create
          end

          it { expect(response).to have_http_status :created }
          it { expect(json['lot']).to be_present }
          it do
            expect(RecalculateQuantityService).
              to have_received(:call!).with(covenant: lot.bidding.covenant)
          end
          it { expect(lot_saved.attachments.size).to eq 1 }
        end

        context 'when not created' do
          before do
            allow(controller.lot).to receive(:save) { true }
            allow(controller.lot).to receive(:errors_as_json) { { error: 'value' } }
            allow(RecalculateQuantityService).
              to receive(:call!).
              with(covenant: lot.bidding.covenant).
              and_raise(ActiveRecord::RecordInvalid)

            post_create
          end

          it do
            expect(RecalculateQuantityService).
              to have_received(:call!).with(covenant: lot.bidding.covenant)
          end
          it { expect(json['errors']).to be_present }
          it { expect(response).to have_http_status :unprocessable_entity }
        end
      end
    end

    context 'without attachments' do
      let(:lot_name) { 'Lote name 002' }
      let(:params) do
        {
          lot: lot.attributes.except('id').merge(
            'name': lot_name,
            lot_group_items_attributes: [lot_group_item.attributes]
          ),
          bidding_id: lot.bidding
        }
      end

      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        let(:lot_saved) { Lot.find_by(name: lot_name) }

        before do
          allow(RecalculateQuantityService).
            to receive(:call!).with(covenant: lot.bidding.covenant) { true }
          post_create
        end

        it { expect(lot_saved.attachments.size).to eq 0 }
      end
    end
  end

  describe '#update' do
    let(:new_name) { 'Updated Lot2' }
    let(:lot_group_item) { build(:lot_group_item, lot: lot, quantity: 10) }

    let(:params) do
      {
        bidding_id: lot.bidding, id: lot,  lot: {
          name: new_name, lot_group_items_attributes: [lot_group_item.attributes]
        }
      }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'lot'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.lot.id).to eq lot.id }
      it { expect(controller.lot.name).to eq new_name }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.lot).to receive(:save) { true }
          allow(RecalculateQuantityService).
            to receive(:call!).with(covenant: lot.bidding.covenant) { true }

          post_update
        end

        it do
          expect(RecalculateQuantityService).
            to have_received(:call!).with(covenant: lot.bidding.covenant)
        end
        it { expect(response).to have_http_status :ok }
        it { expect(json['lot']).to be_present }
      end

      context 'when not updated' do
        context 'response' do
          before do
            allow(controller.lot).to receive(:update) { true }
            allow(controller.lot).to receive(:errors_as_json) { { error: 'value' } }
            allow(RecalculateQuantityService).
              to receive(:call!).
              with(covenant: lot.bidding.covenant).
              and_raise(RecalculateItemError)

            post_update
          end

          it do
            expect(RecalculateQuantityService).
              to have_received(:call!).with(covenant: lot.bidding.covenant)
          end
          it { expect(response).to have_http_status :unprocessable_entity }
        end

        context 'errors' do
          let(:lot_group_item) { build(:lot_group_item, lot: lot, quantity: nil) }
          let(:lot_group_item_errors) { { error: 'value' } }

          before do
            allow(controller.lot).to receive(:errors_as_json) { lot_group_item_errors }
            post_update
          end

          it { expect(json.dig('errors', 'error')).to eq 'value' }
        end

      end
    end
  end

  describe '#destroy' do
    let(:params) { { bidding_id: covenant, id: lot } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'lot'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.lot).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.lot).to receive(:destroy) { false }
          allow(controller.lot).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

end
