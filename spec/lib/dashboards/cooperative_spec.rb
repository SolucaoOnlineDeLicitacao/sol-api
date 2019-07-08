require 'rails_helper'
require './lib/dashboards/cooperative'

RSpec.describe Dashboards::Cooperative, type: :service do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let!(:all_biddings) { create_list :bidding, 2, :with_invites, covenant: covenant, status: :ongoing }
  let!(:biddings) { Bidding.active.sorted }

  let(:service) { described_class.new(biddings: biddings) }

  before do
    allow(biddings).to receive(:limit).with(described_class::LIMIT) { biddings }
  end

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
