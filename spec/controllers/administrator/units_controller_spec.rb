require 'rails_helper'

RSpec.describe Administrator::UnitsController, type: :controller do
  let(:serializer) { UnitSerializer }
  let(:user) { create :admin }
  let!(:units) { create_list(:unit, 2) }

  before { oauth_token_sign_in user }

  describe '#index' do
    subject(:get_index) { get :index, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Unit }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.units).to eq units }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { units.map { |unit| format_json(serializer, unit) } }

        it { expect(json).to eq expected_json }
      end
    end
  end
end
