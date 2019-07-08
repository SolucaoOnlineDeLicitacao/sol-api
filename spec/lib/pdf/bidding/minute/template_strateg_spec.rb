require 'rails_helper'

RSpec.describe Pdf::Bidding::Minute::TemplateStrategy do
  let(:bidding) { create(:bidding, status: status) }

  describe '#decide' do
    subject { described_class.decide(bidding: bidding) }

    context 'when status is finnished' do
      let(:status) { :finnished }

      it { is_expected.to be_kind_of(Pdf::Bidding::Minute::FinnishedHtml) }
    end

    context 'when status is failure' do
      let(:status) { :failure }

      it { is_expected.to be_kind_of(Pdf::Bidding::Minute::FailureHtml) }
    end

    context 'when status is desert' do
      let(:status) { :desert }

      it { is_expected.to be_kind_of(Pdf::Bidding::Minute::DesertHtml) }
    end
  end
end
