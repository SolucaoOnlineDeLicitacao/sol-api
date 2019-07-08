require 'rails_helper'

RSpec.describe BiddingsService::ProposalImports::Download, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding_id: bidding.id } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding_id).to eq bidding.id }
    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call' do
    let(:download_all_service_params) do
      { bidding: bidding, file_type: 'xlsx' }
    end
    let(:file_path) { File.join(Rails.root, '/spec/fixtures/myfiles/file.pdf') }

    before do
      allow(BiddingsService::Download::All).
        to receive(:call).with(download_all_service_params).
        and_return(file_path)
    end

    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        bidding.reload
      end

      it { expect(bidding.proposal_import_file.url).to include 'file.pdf' }
      it do
        expect(BiddingsService::Download::All).
          to have_received(:call).with(download_all_service_params)
      end
    end

    context 'when error' do
      before do
        allow(BiddingsService::Download::All).
          to receive(:call).with(download_all_service_params).
          and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
