require 'rails_helper'

RSpec.describe Coop::ClassificationsController, type: :controller do
  let(:serializer) { ClassificationSerializer }
  let(:user) { create(:user) }

  let!(:parents_classifications) { create_list(:classification, 3) }
  let!(:child_classification) { create(:classification, classification: parents_classifications[1]) }

  let(:classifications) { parents_classifications }

  let(:sorted_classifications) do
    Classification.where(id: parents_classifications.map(&:id)).sorted
  end

  before { oauth_token_sign_in user }

  describe '#index' do

    subject(:get_index) { get :index, xhr: true }

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.classifications).to eq Classification.parent_classifications.sorted }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) do
          sorted_classifications.map { |classification| format_json(serializer, classification) }
        end

        it { expect(json).to eq expected_json }
      end
    end
  end

end
