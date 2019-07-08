require 'rails_helper'

RSpec.describe Pdf::Merge do
  let(:documents) { create_list(:document, 2) }
  let(:params) { { documents: documents } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.documents).to eq(documents) }
  end

  describe '.call' do
    let(:unix_timestamp) { 1552410032 }
    let(:rand_value) { 12345 }
    let(:filename) { "#{unix_timestamp}_#{rand_value}_merged_minute.pdf" }
    let(:file_path) { Rails.root.join('storage', filename) }
    let(:file_size) { File.size(file_path) }
    let(:file_exists?) { File.exists?(file_path) }

    before do
      allow(DateTime).to receive(:current).and_return(unix_timestamp)
      allow(Random).to receive(:rand).with(99999).and_return(rand_value)

      subject
    end

    subject { described_class.call(params) }

    context 'when documents is present' do
      it { expect(subject.path).to eq(file_path.to_s) }
      it { expect(file_exists?).to be_truthy }
      it { expect(file_size).to be > 0 }
    end

    context 'when documents is nil' do
      let(:rand_value) { 12346 }
      let(:documents) { nil }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end

    context 'when documents is blank' do
      let(:rand_value) { 12347 }
      let(:documents) { '' }

      it { is_expected.to be_nil }
      it { expect(file_exists?).to be_falsey }
    end
  end
end
