require 'rails_helper'

RSpec.describe Notifications::Proposals::Suppliers::All, type: :service do
  let!(:bidding)    { create(:bidding, kind: :global, status: :approved) }
  let!(:proposal)   { create(:proposal, bidding: bidding, status: :accepted) }
  let(:service)     { described_class.new(proposals: bidding.proposals) }

  describe 'initialization' do
    it { expect(service.proposals).to eq [proposal] }
  end

  describe 'call' do
    before do
      allow(Notifications::Proposals::Suppliers::Accepted).to receive(:call).with(proposal) { true }
      service.call
    end

    it { expect(Notifications::Proposals::Suppliers::Accepted).to have_received(:call).with(proposal) }
  end
end
