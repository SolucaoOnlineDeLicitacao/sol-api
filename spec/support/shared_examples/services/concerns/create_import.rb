RSpec.shared_examples 'services/concerns/create_import' do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:resource_class) { resource.class.to_s }
  let(:resource_name) { resource_class.underscore.to_s }
  let(:lot_proposal_import?) { resource_name == 'lot_proposal_import' }
  let(:worker) { "#{resource_class.remove('Import')}UploadWorker".constantize }

  describe '#initialize' do
    subject { described_class.new(args) }

    context 'when the returned_lot_group_item is set' do
      it { expect(subject.send(resource_name)).to eq resource }
      it { expect(subject.user).to eq(user) }
      it { expect(subject.bidding).to eq(bidding) }
      it { expect(subject.lot).to eq(lot) if lot_proposal_import? }
    end
  end

  describe '.async_call' do
    before { Sidekiq::Worker.clear_all }

    subject { described_class.async_call(args) }

    context 'when it runs successfully' do
      before { expect(worker).to receive(:perform_async) }

      it { is_expected.to be_truthy }
      it { expect { subject }.to change { resource_class.constantize.count }.by(1) }
    end

    context 'when it runs with failures' do
      context 'and the group_item is invalid' do
        before do
          allow(resource).to receive(:save!).
            and_raise(ActiveRecord::RecordInvalid)

          expect(worker).not_to receive(:perform_async)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { resource_class.constantize.count } }
      end
    end
  end

  describe '.call' do
    subject { described_class.call(args) }

    context 'when it runs successfully' do
      it { is_expected.to be_truthy }
      it { expect { subject }.to change { resource_class.constantize.count }.by(1) }
    end

    context 'when it runs with failures' do
      context 'and the group_item is invalid' do
        before do
          allow(resource).to receive(:save!).
            and_raise(ActiveRecord::RecordInvalid)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { resource_class.constantize.count } }
      end
    end
  end
end
