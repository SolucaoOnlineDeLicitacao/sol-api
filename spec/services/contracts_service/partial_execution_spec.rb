require 'rails_helper'

RSpec.describe ContractsService::PartialExecution, type: :service do
  let!(:user)     { create(:user) }
  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:bidding)  { create(:bidding, status: :finnished, kind: :global) }

  let!(:proposal) do
    create(:proposal, bidding: bidding, provider: provider, status: :accepted)
  end

  let!(:contract) do
    create(:contract, proposal: proposal, user: user, status: :signed,
                      user_signed_at: DateTime.current)
  end

  let(:lot_group_item) do
    proposal.lot_group_item_lot_proposals.map(&:lot_group_item).first
  end

  let(:returned_lot_group_item) do
    build(:returned_lot_group_item, contract: contract,
                                    lot_group_item: lot_group_item)
  end

  let(:permitted_params) do
    [
      :id, returned_lot_group_items_attributes: [
        :id, :lot_group_item_id, :quantity, :_destroy
      ]
    ]
  end

  let(:params) do
    {
      contract: {
        returned_lot_group_items_attributes: [
          {
            '_destroy': false.to_s, quantity: returned_lot_group_item.quantity.to_s,
            lot_group_item_id: returned_lot_group_item.lot_group_item_id.to_s
          }
        ]
      }, 'controller' => 'coop/contract/partial_executions', 'action' => 'update'
    }
  end

  let(:contract_params) do
    ActionController::Parameters.
      new(params).require(:contract).permit(permitted_params)
  end

  let(:args) { { contract: contract, contract_params: contract_params } }

  before do
    allow(Notifications::Contracts::PartialExecution).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).to receive(:call!).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(args) }

    it { expect(subject.contract).to eq contract }
    it { expect(subject.contract_params).to eq contract_params }
  end

  describe '.call' do
    subject { described_class.call(args) }

    context 'when it runs successfully' do
      before do
        expect(RecalculateQuantityService).
          to receive(:call!).with(covenant: contract.bidding.covenant)

        subject
      end

      it do
        expect(contract.reload.lot_group_items).
          to match_array contract.reload.lot_group_items_returned
      end
      it { expect(contract.reload.partial_execution?).to be_truthy }
      it do
        expect(Blockchain::Contract::Update).
          to have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::PartialExecution).
          to have_received(:call).with(contract: contract)
      end
    end

    context 'when it runs with failures' do
      context 'with RecordInvalid error' do
        before do
          allow(contract).
            to receive(:partial_execution!).
            and_raise(ActiveRecord::RecordInvalid)

          expect(RecalculateQuantityService).
            not_to receive(:call!).with(covenant: contract.bidding.covenant)

          subject
        end

        it { is_expected.to be_falsy }
        it { expect(contract.reload.lot_group_items_returned).to be_empty }
        it { expect(contract.reload.partial_execution?).to be_falsey }
        it do
          expect(Notifications::Contracts::PartialExecution).
            to_not have_received(:call).with(contract: contract)
        end
      end

      context 'with RecalculateItemError error' do
        before do
          allow(RecalculateQuantityService).
            to receive(:call!).
            and_raise(RecalculateItemError)

          subject
        end

        it { is_expected.to be_falsy }
        it { expect(contract.reload.lot_group_items_returned).to be_empty }
        it { expect(contract.reload.partial_execution?).to be_falsey }
        it do
          expect(Notifications::Contracts::PartialExecution).
            to_not have_received(:call).with(contract: contract)
        end
      end

      context 'when BC error' do
        before do
          allow(Blockchain::Contract::Update).
            to receive(:call!).with(contract: contract).
            and_raise(BlockchainError)
        end

        it { is_expected.to be_falsy }
        it { expect(contract.reload.partial_execution?).to be_falsy }
        it do
          expect(Notifications::Contracts::PartialExecution).
            to_not have_received(:call).with(contract: contract)
        end
      end

      context 'when contract is not signed' do
        before { contract.waiting_signature! }

        it { is_expected.to be_falsy }
      end
    end
  end
end
