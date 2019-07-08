require 'rails_helper'

RSpec.describe ContractsService::SystemRefuse, type: :service do
  include_examples 'services/concerns/init_contract'

  let(:created_at) { 5.days.ago }
  let!(:contract) do
    create(:contract, proposal: proposal, user: user, created_at: created_at,
                      user_signed_at: DateTime.current)
  end

  let!(:system) { create(:system) } 

  let(:comment) { I18n.t('services.contracts.system_refuse.comment') } 

  before do
    allow(Notifications::Contracts::Refused).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).
      to receive(:call!).with(contract: contract).and_return(true)
  end

  describe '.call' do
    subject { described_class.call }

    context 'when success' do
      before do
        subject
        contract.reload
      end

      context 'and the contract was created 5 days ago' do
        context 'and the contract is signed' do
          let!(:contract) do
            create(:contract, proposal: proposal, user: user,
                              user_signed_at: DateTime.current, status: :signed)
          end

          it { expect(contract.refused?).to be_falsey }
          it { expect(contract.refused_by_id).to be_nil }
          it { expect(contract.refused_by_type).to be_nil }
          it { expect(contract.refused_by_at).to be_nil }
        end

        context 'and the contract has supplier' do
          let!(:contract) do
            create(:contract, proposal: proposal, user: user,
                              created_at: created_at,
                              user_signed_at: DateTime.current,
                              supplier: supplier,
                              supplier_signed_at: DateTime.current)
          end

          it { expect(contract.refused?).to be_falsey }
          it { expect(contract.refused_by_id).to be_nil }
          it { expect(contract.refused_by_type).to be_nil }
          it { expect(contract.refused_by_at).to be_nil }
        end

        context 'and the contract is waiting_signature' do
          it { expect(contract.refused?).to be_truthy }
          it { expect(contract.refused_by_id).to eq system.id }
          it { expect(contract.refused_by_type).to eq system.class.to_s }
          it do
            expect(contract.refused_by_at).
              to be_kind_of(ActiveSupport::TimeWithZone)
          end
        end
      end

      context 'and the contract was recently created' do
        let(:created_at) { 4.days.ago }

        it { expect(contract.refused?).to be_falsey }
        it { expect(contract.refused_by_id).to be_nil }
        it { expect(contract.refused_by_type).to be_nil }
        it { expect(contract.refused_by_at).to be_nil }
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(ContractsService::Refused).
          to receive(:call!).
          with(contract: contract, refused_by: system, comment: comment).
          and_raise(ActiveRecord::RecordInvalid)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '.call!' do
    subject { described_class.call! }

    context 'when success' do
      before do
        subject
        contract.reload
      end

      context 'and the contract was created 5 days ago' do
        context 'and the contract is signed' do
          let!(:contract) do
            create(:contract, proposal: proposal, user: user,
                              user_signed_at: DateTime.current, status: :signed)
          end

          it { expect(contract.refused?).to be_falsey }
          it { expect(contract.refused_by_id).to be_nil }
          it { expect(contract.refused_by_type).to be_nil }
          it { expect(contract.refused_by_at).to be_nil }
        end

        context 'and the contract has supplier' do
          let!(:contract) do
            create(:contract, proposal: proposal, user: user,
                              created_at: created_at,
                              user_signed_at: DateTime.current,
                              supplier: supplier,
                              supplier_signed_at: DateTime.current)
          end

          it { expect(contract.refused?).to be_falsey }
          it { expect(contract.refused_by_id).to be_nil }
          it { expect(contract.refused_by_type).to be_nil }
          it { expect(contract.refused_by_at).to be_nil }
        end

        context 'and the contract is waiting_signature' do
          it { expect(contract.refused?).to be_truthy }
          it { expect(contract.refused_by_id).to eq system.id }
          it { expect(contract.refused_by_type).to eq system.class.to_s }
          it do
            expect(contract.refused_by_at).
              to be_kind_of(ActiveSupport::TimeWithZone)
          end
        end
      end

      context 'and the contract was recently created' do
        let(:created_at) { 4.days.ago }

        it { expect(contract.refused?).to be_falsey }
        it { expect(contract.refused_by_id).to be_nil }
        it { expect(contract.refused_by_type).to be_nil }
        it { expect(contract.refused_by_at).to be_nil }
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(ContractsService::Refused).
          to receive(:call!).
          with(contract: contract, refused_by: system, comment: comment).
          and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
