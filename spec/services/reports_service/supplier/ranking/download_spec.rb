require 'rails_helper'

RSpec.describe ReportsService::Supplier::Ranking::Download, type: :service do
  let(:report) { create(:report, report_type: :suppliers_contracts) }
  let(:service_call) { described_class.call(report: report) }

  describe 'call' do
    let!(:user) { create(:user) }
    let!(:providers) { create_list(:provider, 2) }
    let(:provider) { providers.first }
    let!(:supplier) { create(:supplier, provider: provider) }
    let!(:another_supplier) { create(:supplier, provider: providers.last) }
    let!(:biddings) { create_list(:bidding, 3, status: :finnished, kind: :global) }
    let!(:proposal_1) { create(:proposal, bidding: biddings[0], provider: provider, status: :accepted) }
    let!(:proposal_2) { create(:proposal, bidding: biddings[1], provider: provider, status: :accepted) }
    let!(:proposal_3) { create(:proposal, bidding: biddings[2], provider: provider, status: :accepted) }

    let!(:contract_1) do
      create(:contract, proposal: proposal_1,
        user: user, user_signed_at: DateTime.current,
        supplier: supplier, supplier_signed_at: DateTime.current)
    end
    let!(:contract_2) do
      create(:contract, proposal: proposal_2,
        user: user, user_signed_at: DateTime.current,
        supplier: supplier, supplier_signed_at: DateTime.current)
    end
    let!(:contract_3) do
      create(:contract, proposal: proposal_3,
        user: user, user_signed_at: DateTime.current,
        supplier: supplier, supplier_signed_at: DateTime.current)
    end

    let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
    let(:sheet) { file_xlsx.worksheet 0 }
    let(:sheet1) { file_xlsx.worksheet 1 }
    let(:date_time) { DateTime.new(2015, 7, 19, 13, 40) }
    let(:price_total_provider) { [contract_1, contract_2, contract_3].map(&:proposal).sum(&:price_total) }

    context 'when it runs successfully' do
      before do
        allow(DateTime).to receive(:current).and_return(date_time)
        service_call
      end

      it { expect(report.success?).to be_truthy }
      it { expect(report.url).to match /storage\/ranking_fornecedores_.*\.xls$/ }
      it { expect(report.error_message).to be_nil }
      it { expect(report.error_backtrace).to be_nil }
      it { expect(file_xlsx).to be_present }

      it { expect(sheet.row(2)[0]).to eq provider.name }
      it { expect(sheet.row(2)[1]).to eq 3 }
      it { expect(sheet.row(2)[2]).to eq ActionController::Base.helpers.number_to_currency(price_total_provider) }
      it { expect(sheet.row(3)).to eq [] }

      it { expect(sheet1.row(1)[0]).to eq provider.name }
      it { expect(sheet1.row(1)[1]).to eq provider.document }
      it { expect(sheet1.row(1)[2]).to eq "##{contract_1.id}" }
      it { expect(sheet1.row(1)[3]).to eq contract_1.proposal.bidding.cooperative.name }
      it { expect(sheet1.row(1)[4]).to eq contract_1.proposal.bidding.cooperative.cnpj }
      it { expect(sheet1.row(1)[5]).to eq contract_1.proposal.bidding.title }
      it { expect(sheet1.row(1)[6]).to eq ActionController::Base.helpers.number_to_currency(contract_1.proposal.price_total) }

      it { expect(sheet1.row(2)[0]).to eq provider.name }
      it { expect(sheet1.row(2)[1]).to eq provider.document }
      it { expect(sheet1.row(2)[2]).to eq "##{contract_2.id}" }
      it { expect(sheet1.row(2)[3]).to eq contract_2.proposal.bidding.cooperative.name }
      it { expect(sheet1.row(2)[4]).to eq contract_2.proposal.bidding.cooperative.cnpj }
      it { expect(sheet1.row(2)[5]).to eq contract_2.proposal.bidding.title }
      it { expect(sheet1.row(2)[6]).to eq ActionController::Base.helpers.number_to_currency(contract_2.proposal.price_total) }

      it { expect(sheet1.row(3)[0]).to eq provider.name }
      it { expect(sheet1.row(3)[1]).to eq provider.document }
      it { expect(sheet1.row(3)[2]).to eq "##{contract_3.id}" }
      it { expect(sheet1.row(3)[3]).to eq contract_3.proposal.bidding.cooperative.name }
      it { expect(sheet1.row(3)[4]).to eq contract_3.proposal.bidding.cooperative.cnpj }
      it { expect(sheet1.row(3)[5]).to eq contract_3.proposal.bidding.title }
      it { expect(sheet1.row(3)[6]).to eq ActionController::Base.helpers.number_to_currency(contract_3.proposal.price_total) }
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
