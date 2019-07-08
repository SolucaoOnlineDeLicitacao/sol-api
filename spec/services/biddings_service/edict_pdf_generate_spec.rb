require 'rails_helper'

RSpec.describe BiddingsService::EdictPdfGenerate, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding: bidding, file_type: 'edict' } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    let(:edict_pdf_generate_return) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/file.pdf")
      )
    end

    before do
      allow(Pdf::Bidding::Edict::TemplateHtml).to receive(:call).and_return(nil)
      allow(Pdf::Builder::Bidding).
        to receive(:call).and_return(edict_pdf_generate_return)
    end

    subject { described_class.call!(params) }

    context 'when it runs successfully' do
      context 'and Pdf::Builder::Bidding returns a file' do
        it { is_expected.to be_truthy }

        describe 'the edict_document' do
          before { subject }

          it { expect(bidding.edict_document).to be_present }
          it { expect(bidding.edict_document.file).to be_present }
        end
      end

      context 'and Pdf::Builder::Bidding returns nil' do
        let(:edict_pdf_generate_return) { nil }

        it { is_expected.to be_truthy }

        describe 'the edict_document' do
          before { subject }

          it { expect(bidding.edict_document).to be_nil }
        end
      end

      context 'and the bidding already have a edict_document' do
        let(:edict_document) { create(:document) }
        let(:bidding) { create(:bidding, edict_document: edict_document) }
        let(:edict_pdf_generate_return) do
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec/fixtures/myfiles/file2.pdf")
          )
        end

        it { is_expected.to be_truthy }
        it { expect { subject }.to_not change { bidding.edict_document } }

        describe 'the edict_document' do
          before { subject }

          it { expect(bidding.edict_document.file.filename).to eq('file2.pdf')}
        end
      end
    end

    context 'when it runs with failures' do
      let(:error) { ActiveRecord::RecordInvalid }

      context 'and Document.create! error' do
        before { allow(Document).to receive(:create!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end

      context 'and bidding.update! error' do
        before { allow(bidding).to receive(:update!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end
    end
  end
end
