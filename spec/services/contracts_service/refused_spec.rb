require 'rails_helper'

RSpec.describe ContractsService::Refused, type: :service do
  include_examples 'services/concerns/init_contract'

  let(:comment) { 'Comment refused' }
  let(:refused_by) { supplier }
  let(:event_params) { { contract: contract, comment: comment, user: refused_by } } 
  let(:params) { { contract: contract, refused_by: refused_by, comment: comment } }

  before do
    allow(Notifications::Contracts::Refused).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).
      to receive(:call!).with(contract: contract).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    subject { described_class.new(params) }

    context 'when success' do
      before do
        allow(EventServices::Contract::Refused).to receive(:new).with(event_params).and_call_original
        subject.call
      end

      it { expect(EventServices::Contract::Refused).to have_received(:new).with(event_params) }

      context 'and refused by Supplier' do
        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq(supplier.id) }
        it { expect(contract.refused_by_type).to eq('Supplier') }
        it do
          expect(contract.refused_by_at).
            to be_kind_of(ActiveSupport::TimeWithZone)
        end
        it do
          expect(Notifications::Contracts::Refused).
            to have_received(:call).with(contract: contract)
        end
        it do
          expect(Blockchain::Contract::Update).
            to have_received(:call!).with(contract: contract)
        end
      end

      context 'and refused by System' do
        let!(:system) { create(:system) } 
        let(:refused_by) { system }

        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq system.id }
        it { expect(contract.refused_by_type).to eq('System') }
        it do
          expect(contract.refused_by_at).
            to be_kind_of(ActiveSupport::TimeWithZone)
        end
        it do
          expect(Notifications::Contracts::Refused).
            to have_received(:call).with(contract: contract)
        end
        it do
          expect(Blockchain::Contract::Update).
            to have_received(:call!).with(contract: contract)
        end
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(EventServices::Contract::Refused).to receive(:call).with(event_params).and_call_original
        allow(contract).
          to receive(:refused!).and_raise(ActiveRecord::RecordInvalid)
        subject.call
      end

      it { expect(contract.refused?).to be_falsey }
      it do
        expect(Notifications::Contracts::Refused).
          to_not have_received(:call).with(contract: contract)
      end
      it do
        expect(EventServices::Contract::Refused).
          to_not have_received(:call).with(event_params)
      end
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
    end

    context 'when BC error' do
      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).and_raise(BlockchainError)
        subject.call
      end

      it { expect(contract.reload.refused?).to be_falsey }
      it do
        expect(Blockchain::Contract::Update).
          to have_received(:call!).with(contract: contract)
      end
    end

    context 'when Event error' do
      let(:event_service) { subject.event_service }
      let(:event) { event_service.event }
      let(:error_event_key) { [:comment] } 

      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).with(contract: contract).and_return(true)
        params[:comment] = ''
        subject.call
      end

      it { expect(contract.reload.refused?).to be_falsey }
      it { expect(event.errors.messages.keys).to eq error_event_key }
    end
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when success' do
      before { subject }

      context 'and refused by Supplier' do
        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq(supplier.id) }
        it { expect(contract.refused_by_type).to eq('Supplier') }
        it do
          expect(contract.refused_by_at).
            to be_kind_of(ActiveSupport::TimeWithZone)
        end
        it do
          expect(Notifications::Contracts::Refused).
            to have_received(:call).with(contract: contract)
        end
        it do
          expect(Blockchain::Contract::Update).
            to have_received(:call!).with(contract: contract)
        end
      end

      context 'and refused by Admin' do
        let(:admin) { create(:admin) }
        let(:refused_by) { admin }

        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq(admin.id) }
        it { expect(contract.refused_by_type).to eq('Admin') }
        it do
          expect(contract.refused_by_at).
            to be_kind_of(ActiveSupport::TimeWithZone)
        end
        it do
          expect(Notifications::Contracts::Refused).
            to have_received(:call).with(contract: contract)
        end
        it do
          expect(Blockchain::Contract::Update).
            to have_received(:call!).with(contract: contract)
        end
      end

      context 'and refused by System' do
        let!(:system) { create(:system) } 
        let(:refused_by) { system }

        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq system.id }
        it { expect(contract.refused_by_type).to eq('System') }
        it do
          expect(contract.refused_by_at).
            to be_kind_of(ActiveSupport::TimeWithZone)
        end
        it do
          expect(Notifications::Contracts::Refused).
            to have_received(:call).with(contract: contract)
        end
        it do
          expect(Blockchain::Contract::Update).
            to have_received(:call!).with(contract: contract)
        end
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(contract).
          to receive(:refused!).and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      it do
        expect(Notifications::Contracts::Refused).
          to_not have_received(:call).with(contract: contract)
      end
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
    end

    context 'when BC error' do
      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).and_raise(BlockchainError)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      it do
        expect(Notifications::Contracts::Refused).
          to_not have_received(:call).with(contract: contract)
      end
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
    end
  end
end
