require 'rails_helper'

RSpec.describe AdditiveService, type: :service do
  let(:additive) { build(:additive, bidding: bidding, to: Date.current+2.month) }
  let(:bidding) { create(:bidding, closing_date: old_closing_date) }
  let!(:old_closing_date) { Date.current+5.days }
  let(:params) { { additive: additive } }

  describe 'initialization' do
    let(:service) { described_class.new(params) }

    it { expect(service.additive).to eq additive }
  end

  describe '.call' do
    let(:worker) { Bidding::EdictPdfGenerateWorker }

    before do
      allow(Notifications::Biddings::Additives::Created).to receive(:call).with(bidding)
    end

    subject { described_class.call(params) }

    context 'when it runs successfully' do
      context 'and the bidding is successfully additived' do
        it { is_expected.to be_truthy }
        it { expect { subject }.to change { Additive.count }.by(1) }

        context 'and the bid closing date has to be updated' do
          before { subject }

          it { expect(Notifications::Biddings::Additives::Created).to have_received(:call).with(bidding) }
          it { expect(additive.from).to eq(old_closing_date) }
          it { expect(additive.bidding.closing_date).to eq(additive.to) }
          it { expect(worker.jobs.size).to eq(1) }
        end
      end
    end

    context 'when it runs with failures' do
      context 'and the additive is less than the bid closing date' do
        let(:additive) { build(:additive, :with_retroactive_date) }

        it { is_expected.to be_falsey }
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'and an exception is thrown' do
        let(:additive) { build(:additive) }

        before { allow(additive).to receive(:save!) { raise ActiveRecord::RecordInvalid } }

        it { expect(Notifications::Biddings::Additives::Created).not_to have_received(:call).with(bidding) }
        it { is_expected.to be_falsey }
        it { expect(worker.jobs.size).to eq(0) }
      end
    end
  end
end
