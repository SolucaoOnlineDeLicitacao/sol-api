require 'rails_helper'

RSpec.describe BiddingsService::Approve, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call' do
    let(:proposal_import_file_worker) do
      Bidding::ProposalImportFileGenerateWorker
    end
    let(:lot_proposal_import_file_worker) do
      Bidding::LotProposalImportFileGenerateWorker
    end
    let(:edict_pdf_worker) { Bidding::EdictPdfGenerateWorker }
    let(:api_response) { double('api_response', success?: true) }

    before do
      allow(Blockchain::Bidding::Create).
        to receive(:call).with(bidding).and_return(api_response)
      allow(Notifications::Biddings::Approved).
        to receive(:call).with(bidding).and_return(true)
    end

    subject { described_class.call(params) }

    context 'when success' do
        before do
          subject
          bidding.reload
        end

        it { expect(bidding.approved?).to be_truthy }
        it do
          expect(Blockchain::Bidding::Create).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Approved).
            to have_received(:call).with(bidding)
        end
        it { expect(proposal_import_file_worker.jobs.size).to eq(1) }
        it { expect(lot_proposal_import_file_worker.jobs.size).to eq(1) }
        it { expect(edict_pdf_worker.jobs.size).to eq(1) }
    end

    context 'when error' do
      context 'and bidding has errors' do
        before do
          allow(bidding).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

          subject
          bidding.reload
        end

        it { expect(bidding.approved?).to be_falsey }
        it do
          expect(Blockchain::Bidding::Create).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Approved).
            not_to have_received(:call).with(bidding)
        end
        it { expect(proposal_import_file_worker.jobs.size).to eq(0) }
        it { expect(lot_proposal_import_file_worker.jobs.size).to eq(0) }
        it { expect(edict_pdf_worker.jobs.size).to eq(0) }
      end

      context 'and blockchain has errors' do
        let(:api_response) { double('api_response', success?: false) }

        before do
          subject
          bidding.reload
        end

        it { expect(bidding.approved?).to be_falsey }
        it do
          expect(Notifications::Biddings::Approved).
            not_to have_received(:call).with(bidding)
        end
        it { expect(proposal_import_file_worker.jobs.size).to eq(0) }
        it { expect(lot_proposal_import_file_worker.jobs.size).to eq(0) }
        it { expect(edict_pdf_worker.jobs.size).to eq(0) }
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
