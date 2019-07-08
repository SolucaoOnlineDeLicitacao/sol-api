require 'rails_helper'

RSpec.describe BiddingsService::Upload::All::Strategy do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:import) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:params) { { user: user, import: import } }

  describe '.decide' do
    subject { described_class.decide(params) }

    context 'when xls' do
      it { is_expected.to be_instance_of(BiddingsService::Upload::All::Xls) }
    end

    context 'when xlsx' do
      let(:import) do
        create(:proposal_import, :with_xlsx, bidding: bidding, provider: provider)
      end

      it { is_expected.to be_instance_of(BiddingsService::Upload::All::Xlsx) }
    end
  end
end
