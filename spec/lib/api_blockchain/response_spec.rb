require 'rails_helper'

RSpec.describe ApiBlockchain::Response do
  let(:verb) { 'POST' }

  describe '#initialize' do
    subject { described_class.new(status: 200, body: { 'key': 'param' }, verb: verb) }

    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :body }
  end

  describe 'body' do
    subject { described_class.new(status: 200, body: body, verb: verb).body }

    context 'when empty' do
      let(:body) { {} }

      it { is_expected.to eq [{}] }
    end

    context 'when present' do
      let!(:body) { { 'id': 60 } }

      it { is_expected.to eq [{ id: 60 }] }
    end
  end

  describe 'success?' do
    context 'when PUT/POST verb' do
      let(:status) { 200 }
      subject { described_class.new(status: status, body: {}, verb: verb).success? }

      context 'when 200' do
        it { is_expected.to be_truthy }
      end

      context 'when not 200' do
        let!(:status) { 300 }

        it { is_expected.to be_falsy }
      end
    end

    context 'when DELETE verb' do
      let(:status) { 204 }
      let!(:verb) { 'DELETE' }
      subject { described_class.new(status: status, body: {}, verb: verb).success? }

      context 'when 204' do
        it { is_expected.to be_truthy }
      end

      context 'when not 204' do
        let!(:status) { 300 }

        it { is_expected.to be_falsy }
      end
    end
  end
end
