require 'rails_helper'

RSpec.describe ReportsService::Contract, type: :service do
  let(:service_call) { described_class.call }
  let!(:classification_1) { create(:classification, name: 'BENS') }
  let!(:classification_2) { create(:classification, name: 'OBRAS') }
  let!(:classification_3) { create(:classification, name: 'SERVIÇOS') }
  let!(:classification_4) do
    create(:classification, name: 'BENS 2', classification_id: classification_3.id)
  end

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }
  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe 'call' do
    context 'without bidding' do
      let(:result) do
        [
          {
            label: classification_1.name,
            data: {
              countable: 0,
              price_total: 0.0
            }
          },
          {
            label: classification_2.name,
            data: {
              countable: 0,
              price_total: 0.0
            }
          },
          {
            label: classification_3.name,
            data: {
              countable: 0,
              price_total: 0.0
            }
          }
        ]
      end

      it { expect(service_call).to match_array result }
    end

    context 'with contracts' do
      include_examples 'services/concerns/contract_classification'

      let!(:item_5) { create(:item, classification: classification_4) }
      let!(:group_item_5) { create(:group_item, group: group_3, item: item_5) }
      let!(:lot_group_item_5) do
        create(:lot_group_item, group_item: group_item_5, lot: lot_4)
      end
      let!(:lot_group_item_lot_proposal_5) do
        create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_4,
            lot_group_item: lot_group_item_5)
      end

      let(:result) do
        [
          {
            label: classification_1.name,
            data: {
              countable: 1,
              price_total: contract_4.proposal.price_total
            }
          },
          {
            label: classification_2.name,
            data: {
              countable: 1,
              price_total: contract_2.proposal.price_total
            }
          },
          {
            label: classification_3.name,
            data: {
              countable: 2,
              price_total: contract_3.proposal.price_total + contract_5.proposal.price_total
            }
          }
        ]
      end

      before do
        proposal_2.accepted!
        proposal_3.accepted!
        proposal_4.accepted!
        proposal_6.accepted!
      end

      it { expect(service_call).to eq result }
    end
  end
end
