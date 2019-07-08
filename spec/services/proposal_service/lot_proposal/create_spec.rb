require 'rails_helper'

RSpec.describe ProposalService::LotProposal::Create, type: :service do
  describe '.call' do
    let(:proposal) { create(:proposal, status: :sent) }
    let(:lot_proposal) { build(:lot_proposal, proposal: proposal) }

    subject { described_class.call(lot_proposal: lot_proposal) }

    context 'when it runs successfully' do
      it { is_expected.to be_truthy }
      it { expect { subject }.to change { LotProposal.count } }
    end

    context 'when it runs with failures' do
      context 'and the lot proposal is invalid' do
        before do
          allow(lot_proposal).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.to change { LotProposal.count }.by(0) }
      end
    end
  end
end
