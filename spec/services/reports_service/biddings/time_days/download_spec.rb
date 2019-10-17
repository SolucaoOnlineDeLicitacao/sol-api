require 'rails_helper'

RSpec.describe ReportsService::Biddings::TimeDays::Download, type: :service do
  let(:report) { create(:report, report_type: :time) }
  let(:service_call) { described_class.call(report: report) }

  describe 'call' do
    let!(:bidding_1) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_2) { create(:bidding, status: :finnished, kind: :lot, closing_date: Date.current + 15.days) }
    let!(:bidding_3) { create(:bidding, status: :finnished, kind: :global, closing_date: Date.current + 15.days) }
    let!(:bidding_4) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_5) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_6) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_7) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_8) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }
    let!(:bidding_9) { create(:bidding, status: :finnished, kind: :unitary, closing_date: Date.current + 15.days) }

    let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
    let(:sheet) { file_xlsx.worksheet 0 }
    let(:sheet1) { file_xlsx.worksheet 1 }
    let(:date_time) { DateTime.new(2015, 7, 19, 13, 40) }

    context 'when it runs successfully' do
      before do
        allow(DateTime).to receive(:current).and_return(date_time)
        service_call
      end

      it { expect(report.success?).to be_truthy }
      it { expect(report.url).to match /storage\/licitacao_time_.*\.xls$/ }
      it { expect(report.error_message).to be_nil }
      it { expect(report.error_backtrace).to be_nil }
      it { expect(file_xlsx).to be_present }

      it { expect(sheet.row(2)[0]).to eq bidding_9.title }
      it { expect(sheet.row(3)[0]).to eq bidding_8.title }
      it { expect(sheet.row(4)[0]).to eq bidding_7.title }
      it { expect(sheet.row(5)[0]).to eq bidding_6.title }
      it { expect(sheet.row(6)[0]).to eq bidding_5.title }
      it { expect(sheet.row(7)[0]).to eq bidding_4.title }
      it { expect(sheet.row(8)[0]).to eq bidding_3.title }
      it { expect(sheet.row(9)[0]).to eq bidding_2.title }
      it { expect(sheet.row(10)[0]).to eq bidding_1.title }

      it { expect(sheet.row(2)[1]).to eq '14 dias' }
      it { expect(sheet.row(3)[1]).to eq '14 dias' }
      it { expect(sheet.row(4)[1]).to eq '14 dias' }
      it { expect(sheet.row(5)[1]).to eq '14 dias' }
      it { expect(sheet.row(6)[1]).to eq '14 dias' }
      it { expect(sheet.row(7)[1]).to eq '14 dias' }
      it { expect(sheet.row(8)[1]).to eq '14 dias' }
      it { expect(sheet.row(9)[1]).to eq '14 dias' }
      it { expect(sheet.row(10)[1]).to eq '14 dias' }

      it { expect(sheet1.row(1)[2]).to eq bidding_9.title }
      it { expect(sheet1.row(2)[2]).to eq bidding_8.title }
      it { expect(sheet1.row(3)[2]).to eq bidding_7.title }
      it { expect(sheet1.row(4)[2]).to eq bidding_6.title }
      it { expect(sheet1.row(5)[2]).to eq bidding_5.title }
      it { expect(sheet1.row(6)[2]).to eq bidding_4.title }
      it { expect(sheet1.row(7)[2]).to eq bidding_3.title }
      it { expect(sheet1.row(8)[2]).to eq bidding_2.title }
      it { expect(sheet1.row(9)[2]).to eq bidding_1.title }

      it { expect(sheet1.row(1)[9]).to eq '14 dias' }
      it { expect(sheet1.row(2)[9]).to eq '14 dias' }
      it { expect(sheet1.row(3)[9]).to eq '14 dias' }
      it { expect(sheet1.row(4)[9]).to eq '14 dias' }
      it { expect(sheet1.row(5)[9]).to eq '14 dias' }
      it { expect(sheet1.row(6)[9]).to eq '14 dias' }
      it { expect(sheet1.row(7)[9]).to eq '14 dias' }
      it { expect(sheet1.row(8)[9]).to eq '14 dias' }
      it { expect(sheet1.row(9)[9]).to eq '14 dias' }
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
