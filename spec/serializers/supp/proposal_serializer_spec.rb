require 'rails_helper'

RSpec.describe Supp::ProposalSerializer, type: :serializer do
  let(:object) { create :proposal }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'price_total' => object.price_total.to_s }
    it { is_expected.to include 'current' => object.triage? }
    it { expect(subject['provider']['id']).to eq object.provider.id }

  end

  describe 'associations' do
    describe 'lot_proposals' do
      let(:serialized_lot_proposals) do
        object.reload.lot_proposals.map do |lot_proposal|
          format_json(Supp::LotProposalSerializer, lot_proposal).except('lot_group_item_lot_proposals')
        end
      end

      context 'with one lot_proposal' do
        before { create(:lot_proposal, proposal: object) }

        it { expect(subject['lot_proposals']).to eq serialized_lot_proposals }
      end

      context 'with two lot_proposals' do
        before { @lot_proposals = create_list(:lot_proposal, 2, proposal: object) }

        it { expect(subject['lot_proposals']).to eq serialized_lot_proposals }
        it { expect(subject['lot_proposals'][1]['id']).to eq @lot_proposals.first.id }
        it { expect(subject['lot_proposals'][1]['lot']['id']).to eq @lot_proposals.first.lot_id }
      end
    end
  end
end
