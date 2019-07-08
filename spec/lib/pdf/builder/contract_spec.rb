require 'rails_helper'

RSpec.describe Pdf::Builder::Contract do
  include_examples 'services/concerns/init_contract'

  let(:document) { nil }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      user: user, user_signed_at: DateTime.current,
                      supplier: supplier, supplier_signed_at: DateTime.current,
                      document: document)
  end

  let(:file_type) { 'commodity' }
  let(:html) do
    Pdf::Contract::TemplateStrategy.decide(contract: contract).call
  end

  let(:params) { { header_resource: contract, html: html, file_type: file_type } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.html).to eq(html) }
  end

  describe '.call' do
    let(:unix_timestamp) { 1552410032 }
    let(:rand_value) { 12345 }
    let(:filename) { "#{unix_timestamp}_#{rand_value}_#{file_type}.pdf" }
    let(:file_path) { Rails.root.join('storage', filename) }
    let(:file_size) { File.size(file_path) }
    let(:file_exists?) { File.exists?(file_path) }

    before do
      allow(DateTime).to receive(:current).and_return(unix_timestamp)
      allow(Random).to receive(:rand).with(99999).and_return(rand_value)

      subject
    end

    subject { described_class.call(params) }

    context 'without header' do
      let(:params) { { html: html, file_type: file_type } }

      it { expect(subject.path).to eq(file_path.to_s) }
      it { expect(file_exists?).to be_truthy }
      it { expect(file_size).to be > 0 }
    end

    context 'with header' do
      context 'when html is present' do
        context 'and is contract' do
          it { expect(subject.path).to eq(file_path.to_s) }
          it { expect(file_exists?).to be_truthy }
          it { expect(file_size).to be > 0 }
        end

        context 'and is work' do
          let(:file_type) { 'work' }

          it { expect(subject.path).to eq(file_path.to_s) }
          it { expect(file_exists?).to be_truthy }
          it { expect(file_size).to be > 0 }
        end

        context 'and is service' do
          let(:file_type) { 'service' }

          it { expect(subject.path).to eq(file_path.to_s) }
          it { expect(file_exists?).to be_truthy }
          it { expect(file_size).to be > 0 }
        end
      end
    end

    context 'when html is nil' do
      let(:rand_value) { 12346 }
      let(:html) { nil }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end

    context 'when html is blank' do
      let(:rand_value) { 12347 }
      let(:html) { '' }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end
  end
end
