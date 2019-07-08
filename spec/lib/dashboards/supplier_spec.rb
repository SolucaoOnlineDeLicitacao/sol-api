require 'rails_helper'
require './lib/dashboards/supplier'

RSpec.describe Dashboards::Supplier, type: :service do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let!(:biddings) { create_list :bidding, 2, covenant: covenant, status: :ongoing }
  let(:bidding) { biddings.first }

  let(:service) { described_class.new({biddings: biddings}) }

  describe '#initialize' do
    subject { service.biddings }

    it { is_expected.to eq biddings }
  end

  describe 'limit' do
    it { expect(described_class::LIMIT).to eq 10 }
  end

  describe '#to_json' do
    subject { service.to_json[:last_biddings] }

    it { is_expected.to eq biddings.as_json }
  end
end
