require 'rails_helper'

RSpec.describe Coop::BiddingsController, type: :controller do
  let(:serializer) { Coop::BiddingSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:biddings) { create_list(:bidding, 2, :with_invites, covenant: covenant) }
  let(:bidding) { biddings.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Bidding }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:exposed_biddings) { Bidding.all }

      before do
        allow(exposed_biddings).to receive(:search) { exposed_biddings }
        allow(exposed_biddings).to receive(:sorted) { exposed_biddings }
        allow(exposed_biddings).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:biddings) { exposed_biddings }

        get_index
      end

      it { expect(exposed_biddings).to have_received(:search).with('search') }
      it { expect(exposed_biddings).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_biddings).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      let!(:another_bidding) { create(:bidding) }

      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.biddings).to match_array biddings }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { biddings.map { |bidding| format_json(serializer, bidding) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { id: bidding } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.bidding).to eq bidding }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, bidding) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:params) { { bidding: bidding.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'bidding' do
      before do
        allow_any_instance_of(CrudController).
          to receive(:created?) { controller.bidding.save!(validate: false) }
      end
    end

    describe 'exposes' do
      before { post_create }

      it { expect(controller.bidding).to be_a_new Bidding }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.bidding).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['bidding']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.bidding).to receive(:save) { false }
          allow(controller.bidding).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    describe 'with invites' do
      before do
        bidding.update_attributes(status: 0)
      end
      let(:params) do
        {
          bidding: {
            title: bidding.title, description: bidding.description, kind: bidding.kind,
            status: bidding.status, deadline: bidding.deadline, link: bidding.link,
            start_date: bidding.start_date, closing_date: bidding.closing_date,
            covenant_id: bidding.covenant_id, address: bidding.address, modality: bidding.modality,
            classification_id: bidding.classification_id,
            invites_attributes: {
              '0': { '_destroy': false, provider_id: bidding.providers[0].id },
              '1': { '_destroy': false, provider_id: bidding.providers[1].id },
              '2': { '_destroy': true, provider_id: bidding.providers[2].id }
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
          let(:bidding_saved) { Bidding.find(json['bidding']['id']) }

          it { expect(response).to have_http_status :created }
          it { expect(json['bidding']).to be_present }
          it { expect(bidding_saved.providers).to be_present }
          it { expect(bidding_saved.providers.size).to eq 2 }
          it { expect(bidding_saved.providers.size).to_not eq 3 }
        end
      end
    end
  end

  describe '#update' do
    let(:new_title) { 'Updated Bidding' }
    let(:params) { { id: bidding, bidding: { title: new_title } } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.bidding.id).to eq bidding.id }
      it { expect(controller.bidding.title).to eq new_title }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before do
          allow(controller.bidding).to receive(:save) { true }
          post_update
        end

        it { expect(response).to have_http_status :ok }
        it { expect(json['bidding']).to be_present }
      end

      context 'when not updated' do
        before do
          allow(controller.bidding).to receive(:save) { false }
          allow(controller.bidding).to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end

    describe 'with invites' do
      before do
        bidding.update_attributes(status: 0)
      end
      let(:params) do
        {
          id: bidding,
          bidding: {
            title: 'Bidding title 1', description: bidding.description, kind: bidding.kind,
            status: bidding.status, deadline: bidding.deadline, link: bidding.link,
            start_date: bidding.start_date, closing_date: bidding.closing_date,
            covenant_id: bidding.covenant_id, address: bidding.address,
            invites_attributes: {
              '0': { '_destroy': false, provider_id: bidding.providers[0].id },
              '1': { '_destroy': true, provider_id: bidding.providers[1].id },
              '2': { '_destroy': true, provider_id: bidding.providers[2].id }
            }
          }
        }
      end

      subject(:post_update) { patch :update, params: params, xhr: true }

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }

        context 'when created' do
          before do
            post_update
          end
          let(:bidding_saved) { Bidding.find(json['bidding']['id']) }

          it { expect(response).to have_http_status :ok }
          it { expect(json['bidding']).to be_present }
          it { expect(bidding_saved.providers).to be_present }
          it { expect(bidding_saved.title).to_not eq bidding.title }
          it { expect(bidding_saved.providers.size).to eq 4 }
          it { expect(bidding_saved.providers.size).to_not eq 3 }
        end
      end
    end
  end

  describe '#destroy' do
    let(:params) { { id: bidding } }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'bidding'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when destroyed' do
        before do
          allow(controller.bidding).to receive(:destroy) { true }
          delete_destroy
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        before do
          allow(controller.bidding).to receive(:destroy) { false }
          allow(controller.bidding).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

end
