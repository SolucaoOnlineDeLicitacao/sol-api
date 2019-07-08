require 'rails_helper'

RSpec.describe Coop::ProposalSerializer, type: :serializer do
  let(:object) { create :proposal }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:bidding_estimated_cost_total) { object.bidding.estimated_cost_total }

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'bidding_estimated_cost_total' => bidding_estimated_cost_total }
    it { is_expected.to include 'price_total' => object.price_total.to_s }
    it { is_expected.to include 'current' => object.triage? }
    it { expect(subject['provider']['id']).to eq object.provider.id }

  end

  describe 'associations' do
    describe 'lot_proposals' do
      before { create(:lot_proposal, proposal: object) }

      let(:serialized_lot_proposals) do
        object.lot_proposals.map do |lot_proposal|
          format_json(Supp::LotProposalSerializer, lot_proposal).except('lot_group_item_lot_proposals')
        end
      end

      it { is_expected.to include 'lot_proposals' => serialized_lot_proposals }
    end
  end
end
