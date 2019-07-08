require 'rails_helper'

RSpec.describe ContractsService::CalculateDeadline, type: :service do
  let!(:bidding)  { create(:bidding, status: :finnished, kind: :global) }
  let!(:lot_1) { bidding.lots.first }
  let!(:lot_2) { create(:lot, bidding: bidding) }
  let!(:lot_3) { create(:lot, bidding: bidding) }

  let(:lots) { bidding.reload.lots }
  
  describe '#initialize' do
    subject { described_class.new(lots: lots) }

    it { expect(subject.lots).to eq lots }
  end

  describe '.call' do
    subject { described_class.call(lots: lots) }
    
    context 'when lots havent a deadline and get deadline bidding' do
      let(:deadline) { bidding.deadline + 60 } 

      it { expect(subject).to eq deadline }
    end

    context 'when lots have a deadline' do
      before do
        lot_1.update(deadline: 2)
        lot_2.update(deadline: 5)
        lot_3.update(deadline: 3)
      end

      let(:deadline) { lot_2.deadline + 60 }
      
      it { expect(subject).to eq deadline }
    end

    context 'when a lot a deadline' do
      before do
        lot_2.update(deadline: 5)
      end

      let(:deadline) { bidding.deadline + 60 }
      
      it { expect(subject).to eq deadline }
    end
  end
end
