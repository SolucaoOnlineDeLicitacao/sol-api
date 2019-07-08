require 'rails_helper'

RSpec.describe Pdf::Bidding::Minute::DesertHtml do
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    let(:bidding) { create(:bidding) }

    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq(bidding) }
    it { expect(subject.html).to be_present }
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

      # lot 2
      let(:lot_group_item_4) { create(:lot_group_item, group_item: group_item_1) }
      let(:lot_group_item_5) { create(:lot_group_item, group_item: group_item_2) }
      let(:lot_group_item_6) { create(:lot_group_item, group_item: group_item_3) }

      let(:lot_2) do
        create(:lot, lot_base.merge(lot_group_items: [lot_group_item_4, lot_group_item_5, lot_group_item_6]))
      end

      let!(:bidding) { create(:bidding, build_lot: false, lots: [lot_1, lot_2], status: :desert) }

      context 'when there are not invites' do
        let(:file_type) { 'minute_desert' }

        it { is_expected.not_to include("@@") }
      end

      context 'when there are invites' do
        let(:user_1) { create(:supplier) }
        let(:provider_1) { user_1.provider }
        let!(:invite_1) { create(:invite, bidding: bidding, provider: provider_1, status: :approved) }
        let(:user_2) { create(:supplier) }
        let(:provider_2) { user_2.provider }
        let!(:invite_2) { create(:invite, bidding: bidding, provider: provider_2, status: :approved) }
        let(:file_type) { 'minute_desert_invites' }

        it { is_expected.not_to include("@@") }
      end

      after do
        File.write(
          Rails.root.join("spec/fixtures/myfiles/#{file_type}_template.html"),
          subject
        )
      end
    end

    context 'when not able to generate' do
      let(:bidding) { create(:bidding, status: :draft) }

      it { is_expected.to be_nil }
    end
  end
end
