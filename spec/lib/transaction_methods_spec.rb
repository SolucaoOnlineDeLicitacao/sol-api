require 'rails_helper'

class Test; include TransactionMethods end

RSpec.describe TransactionMethods do
  describe '#execute_or_rollback' do
    let(:record) { double(save: true) }
    let(:block) { -> { record.save } }

    subject { Test.new.execute_or_rollback(&block) }

    context 'when it runs successfully' do
      it { is_expected.to be_truthy }
    end

    context 'when it runs with failures' do
      context 'and raises ActiveRecord::RecordInvalid error' do
        before do
          expect(record).
            to receive(:save).and_raise(ActiveRecord::RecordInvalid)
        end

        it { is_expected.to be_falsey }
      end

      context 'and raises ActiveRecord::RecordNotDestroyed error' do
        before { expect(record). to receive(:save).and_raise(ActiveRecord::RecordNotDestroyed) }

        it { is_expected.to be_falsey }
      end

      context 'and raises ActiveRecord::RecordNotUnique error' do
        before { expect(record). to receive(:save).and_raise(ActiveRecord::RecordNotUnique) }

        it { is_expected.to be_falsey }
      end

      context 'and raises BlockchainError error' do
        before { expect(record). to receive(:save).and_raise(BlockchainError) }

        it { is_expected.to be_falsey }
      end

      context 'and raises RecalculateItemError error' do
        before { expect(record). to receive(:save).and_raise(RecalculateItemError) }

        it { is_expected.to be_falsey }
      end

      context 'and raises ArgumentError error' do
        before { expect(record). to receive(:save).and_raise(ArgumentError) }

        it { is_expected.to be_falsey }
      end

      context 'and raises CreateContractError error' do
        before { expect(record). to receive(:save).and_raise(CreateContractError) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
