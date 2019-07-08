require 'rails_helper'

RSpec.describe Administrator::ProposalSerializer, type: :serializer do
  let(:object) { create :proposal }
  let(:options) { { include: { lot_proposals: :lot_group_item_lot_proposals } } }
  let(:provider) { object.provider }

  subject { format_json(described_class, object, options) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'price_total' => object.price_total.to_s }
    it { is_expected.to include 'current' => object.triage? }

    describe 'comment' do
      let!(:change) do
        create(:event_proposal_status_change, from: 'draft', to: object.status,
          eventable: object, comment: 'Oh noes')
      end

      let(:comment) do
        object.event_proposal_status_changes&.changing_to(object.status)
          &.last&.comment
      end

      it { is_expected.to include 'comment' => comment }
    end

    describe 'cancel proposal refused' do
      let!(:change) do
        create(:event_cancel_proposal_refused, from: 'sent', to: object.status,
          eventable: object, comment: 'Oh noes')
      end

      let(:comment) do
        object.event_cancel_proposal_refuseds&.last&.comment
      end

      it { is_expected.to include 'cancel_proposal_refused_comment' => comment }
    end

    describe 'cancel proposal accepted' do
      let!(:change) do
        create(:event_cancel_proposal_accepted, from: 'sent', to: object.status,
          eventable: object, comment: 'Oh noes')
      end

      let(:comment) do
        object.event_cancel_proposal_accepteds&.last&.comment
      end

      it { is_expected.to include 'cancel_proposal_accepted_comment' => comment }
    end

    it { expect(subject['provider']['id']).to eq provider.id }
  end

  describe 'associations' do
    describe 'provider' do
      let(:serialized_provider) { format_json(Administrator::ProviderSerializer, object.provider) }

      it { is_expected.to include 'provider' => serialized_provider }
    end

    describe 'lot_proposals' do
      before { create(:lot_proposal, proposal: object) }

      let(:serialized_lot_proposals) do
        object.lot_proposals.map do |lot_proposal|
          format_json(Administrator::LotProposalSerializer, lot_proposal)
        end
      end

      it { is_expected.to include 'lot_proposals' => serialized_lot_proposals }
    end
  end

end
