require 'rails_helper'

RSpec.describe Search::ClassificationsController, type: :controller do
  let(:user) { create :admin }
  let!(:classifications) { create_list(:classification, 2) }
  let(:classification) { classifications.first }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: classification.name } } }

      before do
        allow(Classification).to receive(:search).with(classification.name, limit).and_call_original
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) do
        {
          id: classification.id,
          classification_id: classification.classification_id,
          text: classification.text
        }.to_json
      end

      it { expect(Classification).not_to have_received(:search).with(classification.name, limit) }
      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq expected_result }
    end
  end
end
