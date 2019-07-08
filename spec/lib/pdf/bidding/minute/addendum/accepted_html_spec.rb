require 'rails_helper'

RSpec.describe Pdf::Bidding::Minute::Addendum::AcceptedHtml do
  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let(:bidding) { create(:bidding, status: :finnished, kind: kind) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, status: status, user: user, supplier: supplier,
                      supplier_signed_at: DateTime.current, user_signed_at: DateTime.current)
  end
  let!(:event_contract_refuseds) { create(:event_contract_refused, eventable: contract) }
  let(:kind) { :global }
  let(:status) { :refused }
  let(:params) { { contract: contract } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq(contract) }
    it { expect(subject.html).to be_present }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when able to generate' do
      context 'when is global' do
        context 'when is refused' do
          let!(:contract) do
            create(:contract, proposal: proposal, status: status, user: user, supplier: supplier,
                              refused_by: supplier, supplier_signed_at: DateTime.current,
                              user_signed_at: DateTime.current)
          end
          let(:file_type) { 'minute_addendum_accepted_refused' }

          it { is_expected.not_to include("@@") }
        end

        context 'when is total_inexecution' do
          let(:status) { :total_inexecution }
          let(:file_type) { 'minute_addendum_accepted_total_inexecution' }

          it { is_expected.not_to include("@@") }
        end
      end

      context 'when is lot' do
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

        let(:bidding) { create(:bidding, build_lot: false, lots: [lot_1, lot_2], kind: kind, status: :finnished) }
        let(:kind) { :lot }

        context 'when is refused' do
          let!(:contract) do
            create(:contract, proposal: proposal, status: status, user: user, supplier: supplier,
                              refused_by: supplier, supplier_signed_at: DateTime.current,
                              user_signed_at: DateTime.current)
          end
          let(:file_type) { 'minute_addendum_accepted_refused_lot' }

          it { is_expected.not_to include("@@") }
        end

        context 'when is total_inexecution' do
          let(:status) { :total_inexecution }
          let(:file_type) { 'minute_addendum_accepted_total_inexecution_lot' }

          it { is_expected.not_to include("@@") }
        end
      end

      after do
        File.write(
          Rails.root.join("spec/fixtures/myfiles/#{file_type}_template.html"),
          subject
        )
      end
    end

    context 'when not able to generate' do
      let(:status) { :signed }

      it { is_expected.to be_nil }
    end
  end
end
