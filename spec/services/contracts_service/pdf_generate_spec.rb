require 'rails_helper'

RSpec.describe ContractsService::PdfGenerate, type: :service do
  include_examples 'services/concerns/init_contract'
  let(:document) { nil }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      user: user, user_signed_at: DateTime.current,
                      supplier: supplier, supplier_signed_at: DateTime.current,
                      document: document)
  end
  let(:params) { { contract: contract, file_type: 'contract' } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call!' do
    let(:pdf_generate_return) do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/myfiles/file.pdf")
      )
    end

    subject { described_class.call!(params) }

    context 'when it runs successfully' do
      context 'and Pdf::Builder::Contract returns a file' do
        it { is_expected.to be_truthy }

        describe 'the document' do
          before { subject }

          it { expect(contract.document).to be_present }
          it { expect(contract.document.file).to be_present }
        end
      end

      context 'and the contract already have a document' do
        let(:document) { create(:document) }
        
        it { is_expected.to be_truthy }
        it { expect { subject }.to_not change { contract.document } }

        describe 'the document' do
          before { subject }

          it { expect(contract.document.file.filename).to_not be_nil }
        end
      end
    end

    context 'when it runs with failures' do
      let(:error) { ActiveRecord::RecordInvalid }

      context 'and Document.create! error' do
        before { allow(Document).to receive(:create!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end

      context 'and contract.update! error' do
        before { allow(contract).to receive(:update!).and_raise(error) }

        it { expect { subject }.to raise_error(error) }
      end
    end
  end
end
