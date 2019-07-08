require 'rails_helper'

RSpec.describe BiddingsService::LotProposalImports::Download, type: :service do
  let(:bidding) { create(:bidding) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:params) { { bidding_id: bidding.id, lot_id: lot.id } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding_id).to eq bidding.id }
    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.lot_id).to eq lot.id }
    it { expect(subject.lot).to eq lot }
  end

  describe '.call' do
    let(:download_lot_service_params) do
      { bidding: bidding, lot: lot, file_type: 'xlsx' }
    end
    let(:file_path) { File.join(Rails.root, '/spec/fixtures/myfiles/file.pdf') }

    before do
      allow(BiddingsService::Download::Lot).
        to receive(:call).with(download_lot_service_params).
        and_return(file_path)
    end

    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        lot.reload
      end

      it { expect(lot.lot_proposal_import_file.url).to include 'file.pdf' }
      it do
        expect(BiddingsService::Download::Lot).
          to have_received(:call).with(download_lot_service_params)
      end
    end

    context 'when error' do
      before do
        allow(BiddingsService::Download::Lot).
          to receive(:call).with(download_lot_service_params).
          and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
