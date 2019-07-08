require 'rails_helper'

RSpec.describe BiddingsService::Minute::PdfGenerate, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    let(:minute_pdf_generate_return) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/file.pdf")
      )
    end
    let(:minute_pdf_merged_return) { minute_pdf_generate_return }

    before do
      allow(Pdf::Bidding::Minute::TemplateStrategy).
        to receive(:decide).and_return(double('call', call: nil))
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

          it { expect(bidding.minute_documents).to be_present }
          it { expect(bidding.minute_documents.size).to eq(1) }
          it { expect(bidding.minute_documents.first.file).to be_present }
          it { expect(bidding.merged_minute_document).to be_present }
        end
      end

      context 'and Pdf::Builder::Bidding returns nil' do
        let(:minute_pdf_generate_return) { nil }

        it { is_expected.to be_truthy }

        describe 'the minute_documents' do
          before { subject }

          it { expect(bidding.minute_documents).to be_blank }
        end
      end

      context 'and the bidding already have minute_documents' do
        let(:minute_document) { create(:document) }
        let(:merged_minute_document) { create(:document) }
        let(:bidding) do
          create(:bidding, merged_minute_document: merged_minute_document,
                           minute_documents: [minute_document])
        end
        let(:minute_pdf_generate_return) do
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec/fixtures/myfiles/file2.pdf")
          )
        end

        it { is_expected.to be_truthy }

        describe 'the minute_documents' do
          before { subject }

          it { expect(bidding.minute_documents).to be_present }
          it { expect(bidding.minute_documents.size).to eq(2) }
          it { expect(bidding.minute_documents.first.file.filename).to eq('file.pdf')}
          it { expect(bidding.minute_documents.last.file.filename).to eq('file2.pdf')}
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
        before { allow(bidding).to receive(:save!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end
    end
  end
end
