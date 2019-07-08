require 'rails_helper'

RSpec.describe Search::CitiesController, type: :controller do
  let(:cities) { create_list(:city, 2) }
  let(:city) { cities.first }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { ActionController::Parameters.new({ search: { term: city.name }, "controller"=>"search/cities", "action"=>"index" }) }
      let(:result_arr) { [{ id: city.id, text: city.text }].to_json }

      before do
        allow(City).to receive(:search).with(city.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params.as_json, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      it { expect(SearchService::Base).to have_received(:call).with(params, City.includes(:state), nil) }
      it { is_expected.to respond_with(:success) }
    end
  end
end
