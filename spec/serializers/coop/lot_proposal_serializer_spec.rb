require 'rails_helper'

RSpec.describe Coop::LotProposalSerializer, type: :serializer do
  let(:proposal) { create :proposal }
  let(:object) { create :lot_proposal, proposal: proposal }
  let(:provider) { proposal.provider }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.lot.bidding_id }
    it { is_expected.to include 'bidding_title' => object.lot.bidding.title }
    it { is_expected.to include 'price_total' => object.price_total.to_s }
    it { is_expected.to include 'delivery_price' => object.delivery_price.to_s }
    it { is_expected.to include 'current' => proposal.triage? }
    it { expect(subject['provider']['id']).to eq provider.id }
  end

  describe 'associations' do
    describe 'lot' do
      let(:serialized_lot) { format_json(Coop::LotSerializer, object.lot) }

      it { is_expected.to include 'lot' => serialized_lot }
    end

    describe 'lot_group_item_lot_proposals' do
      before { create(:lot_group_item_lot_proposal, lot_proposal: object) }

      let(:serialized_lot_group_item_lot_proposals) do
        object.lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
          format_json(Supp::LotGroupItemLotProposalSerializer, lot_group_item_lot_proposal)
        end
      end

      it { is_expected.to include 'lot_group_item_lot_proposals' => serialized_lot_group_item_lot_proposals }
    end
  end
end
