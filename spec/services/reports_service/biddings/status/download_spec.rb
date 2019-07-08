require 'rails_helper'

RSpec.describe ReportsService::Biddings::Status::Download, type: :service do
  let(:report) { create(:report, report_type: :biddings) }
  let(:service_call) { described_class.call(report: report) }

  describe 'call' do
    let!(:bidding_1) { create(:bidding, status: 1, kind: 1) }
    let!(:bidding_2) { create(:bidding, status: 2, kind: 1) }
    let!(:bidding_3) { create(:bidding, status: 3, kind: 1) }

    let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
    let(:sheet) { file_xlsx.worksheet 0 }
    let(:sheet1) { file_xlsx.worksheet 1 }
    let(:date_time) { DateTime.new(2015, 7, 19, 13, 40) }

    let!(:return_bidding_statuses) do
      [
        { label: :waiting,  data: { countable: 1, price_total: 0, estimated_cost: 99.0 } },
        { label: :approved,  data: { countable: 1, price_total: 0, estimated_cost: 20.0 } },
        { label: :ongoing,  data: { countable: 1, price_total: 0, estimated_cost: 143.0 } },
        { label: :draw,  data: { countable: 1, price_total: 0, estimated_cost: 198.0 } },
        { label: :under_review,  data: { countable: 1, price_total: 0, estimated_cost: 130.0 } },
        { label: :finnished,  data: { countable: 1, price_total: 116.0, estimated_cost: 116.0 } },
        { label: :canceled,  data: { countable: 1, price_total: 0, estimated_cost: 186.0 } },
        { label: :suspended,  data: { countable: 1, price_total: 0, estimated_cost: 84.0 } },
        { label: :failure,  data: { countable: 1, price_total: 0, estimated_cost: 128.0 } }
      ]
    end

    context 'when it runs successfully' do
      before do
        allow(ReportsService::Bidding).to receive(:call).with(no_args) { return_bidding_statuses }
        allow(DateTime).to receive(:current).and_return(date_time)
        service_call
      end

      it { expect(ReportsService::Bidding).to have_received(:call).with(no_args) }

      describe 'file' do
        it { expect(report.success?).to be_truthy }
        it { expect(report.url).to match /storage\/licitacao_status_/ }
        it { expect(report.error_message).to be_nil }
        it { expect(report.error_backtrace).to be_nil }
        it { expect(file_xlsx).to be_present  }
      end

      describe 'resume sheet' do
        9.times do |i|
          it { expect(sheet.row(i+2)[1]).to eq return_bidding_statuses[i][:data][:countable] }
          it { expect(sheet.row(i+2)[2]).to eq ActionController::Base.helpers.number_to_currency(return_bidding_statuses[i][:data][:estimated_cost]) }
          it { expect(sheet.row(i+2)[3]).to eq ActionController::Base.helpers.number_to_currency(return_bidding_statuses[i][:data][:price_total]) }
        end
      end

      describe 'detail sheet' do
        it { expect(sheet1.row(1)[2]).to eq bidding_1.title }
        it { expect(sheet1.row(2)[2]).to eq bidding_2.title }
        it { expect(sheet1.row(3)[2]).to eq bidding_3.title }
      end
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
