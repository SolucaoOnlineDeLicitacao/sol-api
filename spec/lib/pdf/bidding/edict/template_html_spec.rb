require 'rails_helper'

RSpec.describe Pdf::Bidding::Edict::TemplateHtml do
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    let(:bidding) { create(:bidding) }

    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq(bidding) }
    it { expect(subject.html).to be_present }
    it { expect(subject.tables_content).to be_empty }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when able to generate' do
      let(:covenant) { create(:covenant) }
      let(:group) { covenant.groups.first }
      let(:admin) { create(:admin) }

      let(:item_2) { create(:item, title: 'Cimento', description: 'Cimento fino', owner: admin) }
      let(:item_3) { create(:item, title: 'Tonner', description: 'Tonner cor preta', owner: admin) }

      let(:group_item_1) { covenant.group_items.first }
      let(:group_item_3) { create(:group_item, group: group, item: item_3) }
      let(:group_item_2) { create(:group_item, group: group, item: item_2) }

      # generic attributes
      let(:lot_base) { { build_lot_group_item: false, status: :accepted } }
      let(:proposal_status) { { status: :accepted } }
      let(:proposal_base_1) { proposal_status.merge(bidding: bidding) }
      let(:proposal_base_2) { proposal_status.merge(bidding: bidding) }

      # lot 1
      let(:lot_group_item_1) { create(:lot_group_item, group_item: group_item_1) }
      let(:lot_group_item_2) { create(:lot_group_item, group_item: group_item_2) }
      let(:lot_group_item_3) { create(:lot_group_item, group_item: group_item_3) }

      let(:lot_1) do
        create(:lot, lot_base.merge(lot_group_items: [lot_group_item_1, lot_group_item_2, lot_group_item_3]))
      end

      let(:proposal_1) { create(:proposal, proposal_base_1) }
      let(:lot_group_item_lot_proposal_1) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_1) }
      let(:lot_group_item_lot_proposal_2) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_2) }
      let(:lot_group_item_lot_proposal_3) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_3) }
      let!(:lot_proposal_1) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false, lot: lot_1, proposal: proposal_1,
                              lot_group_item_lot_proposals: [
                                lot_group_item_lot_proposal_1,
                                lot_group_item_lot_proposal_2,
                                lot_group_item_lot_proposal_3
                              ])
      end

      # lot 2
      let(:lot_group_item_4) { create(:lot_group_item, group_item: group_item_1) }
      let(:lot_group_item_5) { create(:lot_group_item, group_item: group_item_2) }
      let(:lot_group_item_6) { create(:lot_group_item, group_item: group_item_3) }

      let(:lot_2) do
        create(:lot, lot_base.merge(lot_group_items: [lot_group_item_4, lot_group_item_5, lot_group_item_6]))
      end

      let(:proposal_2) { create(:proposal, proposal_base_1) }
      let(:lot_group_item_lot_proposal_4) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_1) }
      let(:lot_group_item_lot_proposal_5) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_2) }
      let(:lot_group_item_lot_proposal_6) { create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_3) }
      let!(:lot_proposal_2) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false, lot: lot_2, proposal: proposal_2,
                              lot_group_item_lot_proposals: [
                                lot_group_item_lot_proposal_4,
                                lot_group_item_lot_proposal_5,
                                lot_group_item_lot_proposal_6
                              ])
      end

      let!(:bidding) { create(:bidding, build_lot: false, lots: [lot_1, lot_2], status: status) }

      after do
        File.write(
          Rails.root.join("spec/fixtures/myfiles/edict_template.html"),
          subject
        )
      end

      context 'when approved' do
        let(:status) { :approved }

        it { is_expected.not_to include("@@") }
      end

      context 'when ongoing' do
        let(:status) { :approved }

        it { is_expected.not_to include("@@") }
      end
    end

    context 'when not able to generate' do
      let!(:bidding) { create(:bidding, status: :draft) }

      it { is_expected.to be_nil }
    end
  end
end
