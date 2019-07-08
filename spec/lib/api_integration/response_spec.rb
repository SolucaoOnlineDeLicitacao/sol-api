require 'rails_helper'

RSpec.describe ApiIntegration::Response do

  describe '#initialize' do
    subject { ApiIntegration::Response.new(status: 200, body: { "key": "param" }) }

    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :body }
  end

  describe 'body' do
    subject { ApiIntegration::Response.new(status: 200, body: body).body }

    context 'when empty' do
      let(:body) { {} }

      it { is_expected.to eq [{}] }
    end

    context 'when present' do
      let!(:body) { { "id": 60 } }

      it { is_expected.to eq [{ id: 60 }] }
    end
  end

  describe 'success?' do
    let(:status) { 200 }
    subject { ApiIntegration::Response.new(status: status, body: {}).success? }

    context 'when 200' do
      it { is_expected.to be_truthy }
    end

    context 'when not 200' do
      let!(:status) { 300 }

      it { is_expected.to be_falsy }
    end
  end
end
