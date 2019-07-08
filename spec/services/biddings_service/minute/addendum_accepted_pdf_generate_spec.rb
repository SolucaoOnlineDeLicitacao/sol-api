require 'rails_helper'

RSpec.describe BiddingsService::Minute::AddendumAcceptedPdfGenerate, type: :service do
  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let(:bidding) { create(:bidding, status: :finnished, kind: :global) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, status: :refused, user: user, user_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call!' do
    let(:minute_pdf_generate_return) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/file.pdf")
      )
    end
    let(:minute_pdf_merged_return) { minute_pdf_generate_return }

    before do
      allow(Pdf::Bidding::Minute::Addendum::AcceptedHtml).
        to receive(:call).and_return(true)
      allow(Pdf::Builder::Bidding).
        to receive(:call).and_return(minute_pdf_generate_return)
      allow(Pdf::Merge).
        to receive(:call).and_return(minute_pdf_merged_return)
    end

    subject { described_class.call!(params) }

    context 'when it runs successfully' do
      context 'and Pdf::Builder::Bidding returns a file' do
        it { is_expected.to be_truthy }

        describe 'the minute_documents' do
          before { subject }

          it { expect(contract.bidding.minute_documents).to be_present }
          it { expect(contract.bidding.minute_documents.size).to eq(1) }
          it { expect(contract.bidding.minute_documents.first.file).to be_present }
          it { expect(contract.bidding.merged_minute_document).to be_present }
        end
      end

      context 'and Pdf::Builder::Bidding returns nil' do
        let(:minute_pdf_generate_return) { nil }

        it { is_expected.to be_truthy }

        describe 'the minute_documents' do
          before { subject }

          it { expect(contract.bidding.minute_documents).to be_blank }
        end
      end

      context 'and the bidding already have minute_documents' do
        let(:minute_document) { create(:document) }
        let(:merged_minute_document) { create(:document) }
        let(:minute_pdf_generate_return) do
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec/fixtures/myfiles/file2.pdf")
          )
        end

        before do
          contract.bidding.update!(
            merged_minute_document: merged_minute_document,
            minute_documents: [minute_document]
          )
        end

        it { is_expected.to be_truthy }

        describe 'the minute_documents' do
          before { subject }

          it { expect(contract.bidding.minute_documents).to be_present }
          it { expect(contract.bidding.minute_documents.size).to eq(2) }
          it { expect(contract.bidding.minute_documents.first.file.filename).to eq('file.pdf')}
          it { expect(contract.bidding.minute_documents.last.file.filename).to eq('file2.pdf')}
        end
      end
    end

    context 'when it runs with failures' do
      let(:error) { ActiveRecord::RecordInvalid }

      context 'and Document.create! error' do
        before { allow(Document).to receive(:create!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end

      context 'and bidding.save! error' do
        before { allow(contract.bidding).to receive(:save!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end
    end
  end
end
