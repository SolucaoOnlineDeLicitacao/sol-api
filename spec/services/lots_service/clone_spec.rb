require 'rails_helper'

RSpec.describe LotsService::Clone, type: :service do
  let!(:pending_invite) { create(:invite, bidding: bidding, status: :pending) }
  let!(:invite) { create(:invite, bidding: bidding, status: :approved) }
  let(:edict_document) { create(:document) }
  let(:minute_document) { create(:document) }
  let(:merged_minute_document) { create(:document) }
  let(:bidding) do
    create(:bidding, status: :canceled,
                     covenant: covenant,
                     edict_document: edict_document,
                     merged_minute_document: merged_minute_document,
                     minute_documents: [minute_document])
  end
  let(:covenant) { create(:covenant) }
  let(:provider) { invite.provider }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let(:service) { described_class.new(proposal: proposal) }

  before do
    allow(RecalculateQuantityService).
      to receive(:call!).with(covenant: proposal.bidding.covenant).and_return(true)
  end

  describe '#initialize' do
    it { expect(service.proposal).to eq proposal }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when success' do
      let(:new_bidding) { Bidding.where(parent_id: bidding.id).first }

      before { service_call }

      it { is_expected.to be_truthy }
      it do
        expect(RecalculateQuantityService).
          to have_received(:call!).with(covenant: proposal.bidding.covenant)
      end

      context 'when bidding is created' do
        let(:attributes) do
          %w[id title status created_at updated_at parent_id code position
             edict_document_id merged_minute_document_id]
        end

        let(:new_bidding_att) { new_bidding.attributes.except(*attributes) }
        let(:bidding_att) { bidding.attributes.except(*attributes) }

        it { expect(new_bidding.draft?).to be_truthy }
        it { expect(new_bidding_att).to match_array bidding_att }
        it { expect(new_bidding.cooperative).to eq bidding.cooperative }
      end

      context 'when lots are created' do
        it { expect(new_bidding.lots.map(&:status)).to eq ['draft'] }
        it { expect(new_bidding.lots.map(&:name)).to include bidding.lots.first.name }
        it { expect(new_bidding.lots.map(&:lot_group_items_count)).to eq [1] }
        it { expect(new_bidding.edict_document).to be_nil }
        it { expect(new_bidding.merged_minute_document).to be_nil }
        it { expect(new_bidding.minute_documents).to be_empty }
      end

      context 'when group_items are created' do
        it { expect(new_bidding.group_items.map(&:item_id)).to include bidding.group_items.first.item_id }
        it { expect(new_bidding.group_items.map(&:quantity)).to include bidding.group_items.first.quantity }
        it { expect(new_bidding.group_item_ids.first).to eq bidding.group_item_ids.first }
      end

      context 'when invites are created' do
        it { expect(new_bidding.provider_ids).to eq [provider.id] }
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow_any_instance_of(described_class).to receive(:clone_lots!) { raise ActiveRecord::RecordInvalid }
      end

      it { is_expected.to be_falsy }
      it do
        expect(RecalculateQuantityService).
          not_to have_received(:call!).with(covenant: proposal.bidding.covenant)
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
