require 'rails_helper'

RSpec.describe ReportsService::Contracts::Kind::Download, type: :service do
  let(:report) { create(:report, report_type: :contracts) }
  let(:service_call) { described_class.call(report: report) }

  describe 'call' do
    let!(:user) { create(:user) }
    let!(:bidding_1) { create(:bidding, status: 6, kind: 1) }
    let!(:bidding_2) { create(:bidding, status: 6, kind: 2) }
    let!(:bidding_3) { create(:bidding, status: 6, kind: 3) }
    let!(:bidding_4) { create(:bidding, status: 6, kind: 3) }

    let!(:providers)  { create_list(:provider, 2, :provider_classifications) }
    let!(:provider)   { providers.first }

    let!(:proposal_1) { create(:proposal, provider: provider, bidding: bidding_1, status: :accepted) }
    let!(:proposal_2) { create(:proposal, provider: provider, bidding: bidding_1, status: :failure) }
    let!(:proposal_3) { create(:proposal, provider: provider, bidding: bidding_2, status: :accepted) }
    let!(:proposal_4) { create(:proposal, provider: provider, bidding: bidding_2, status: :failure) }
    let!(:proposal_5) { create(:proposal, provider: provider, bidding: bidding_2, status: :failure) }
    let!(:proposal_6) { create(:proposal, provider: provider, bidding: bidding_3, status: :accepted) }
    let!(:proposal_7) { create(:proposal, provider: provider, bidding: bidding_4, status: :accepted) }

    let!(:contract_1) { create(:contract, proposal: proposal_1, user: user, user_signed_at: DateTime.current) }
    let!(:contract_2) { create(:contract, proposal: proposal_7, user: user, user_signed_at: DateTime.current) }
    let!(:contract_3) { create(:contract, proposal: proposal_3, user: user, user_signed_at: DateTime.current) }
    let!(:contract_4) { create(:contract, proposal: proposal_6, user: user, user_signed_at: DateTime.current) }

    let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
    let(:sheet) { file_xlsx.worksheet 1 }
    let(:date_time) { DateTime.new(2015, 7, 19, 13, 40) }

    context 'when it runs successfully' do
      before do
        allow(DateTime).to receive(:current).and_return(date_time)
        service_call
      end

      it { expect(report.success?).to be_truthy }
      it { expect(report.url).to match /storage\/classificacao_contrato_/ }
      it { expect(report.error_message).to be_nil }
      it { expect(report.error_backtrace).to be_nil }
      it { expect(file_xlsx).to be_present }

      it { expect(sheet.row(1)[5]).to eq provider.name }
      it { expect(sheet.row(2)[5]).to eq provider.name }
      it { expect(sheet.row(3)[5]).to eq provider.name }
      it { expect(sheet.row(4)[5]).to eq provider.name }

      it { expect(sheet.row(1)[6]).to eq provider.document }
      it { expect(sheet.row(2)[6]).to eq provider.document }
      it { expect(sheet.row(3)[6]).to eq provider.document }
      it { expect(sheet.row(4)[6]).to eq provider.document }
    end

    context 'when it runs with failures' do
      before do
        allow_any_instance_of(described_class).to receive(:download).and_raise(ActiveRecord::RecordInvalid)
        service_call
      end

      it { expect(report.error?).to be_truthy }
      it { expect(report.url).to be_nil }
      it { expect(report.error_message).to be_present }
      it { expect(report.error_backtrace).to be_present }
    end
  end
end
