require 'rails_helper'

RSpec.describe ReportsService::Supplier::Biddings::Download, type: :service do
  let(:report) { create(:report, report_type: :suppliers_biddings) }
  let(:service_call) { described_class.call(report: report) }

  describe 'call' do
    let(:covenant) { create(:covenant) }
    let(:bidding1) do
      create(:bidding, status: :draft, kind: 2, covenant: covenant, build_lot: false)
    end

    let(:bidding2) do
      create(:bidding, status: :draft, kind: 2, covenant: covenant, build_lot: false)
    end

    let(:item1) do
      create(:item, title: "Telha metálica trapezoidal",
        description: "Fornecimento de telhas metálica trapezoidal")
    end

    let(:item2) do
      create(:item, title: "Regador de plástico 5 Litros",
        description: "Regador de plástico capacidade 5 Litros")
    end

    let(:group) do
      group = Group.new(covenant: covenant); group.save(validate: false);
      group
    end

    let(:group_item1) { create(:group_item, group: group, item: item1) }
    let(:group_item2) { create(:group_item, group: group, item: item2) }

    let!(:lot1) do
      lot = Lot.new(id: 1, bidding: bidding1, name: 'Lote A'); lot.save(validate: false); lot
    end

    let!(:lot2) do
      lot = Lot.new(id: 2, bidding: bidding2, name: 'Lote B'); lot.save(validate: false); lot
    end

    let!(:lot3) do
      lot = Lot.new(id: 3, bidding: bidding2, name: 'Lote C'); lot.save(validate: false); lot
    end

    let!(:lot_group_item1) do
      create(:lot_group_item, id: 1, lot: lot1, group_item: group_item1)
    end

    let!(:lot_group_item2) do
      create(:lot_group_item, id: 2, lot: lot2, group_item: group_item2)
    end

    let!(:proposal1) do
      create(:proposal, provider: provider1, bidding: bidding1, status: :accepted)
    end

    let!(:proposal2) do
      create(:proposal, provider: provider1, bidding: bidding2, status: :accepted)
    end

    let!(:proposal3) do
      create(:proposal, provider: provider2, bidding: bidding2, status: :accepted)
    end

    let(:provider1) { create(:provider) }
    let!(:supplier1) { create(:supplier, provider: provider1, name: 'Supplier 1') }
    let(:provider2) { create(:provider) }
    let!(:supplier2) { create(:supplier, provider: provider2, name: 'Supplier 2') }

    let!(:lot_proposal1) do
      create(:lot_proposal, lot: lot1, proposal: proposal1, supplier: supplier1)
    end

    let!(:lot_proposal2) do
      create(:lot_proposal, lot: lot2, proposal: proposal2, supplier: supplier2)
    end

    let(:lot_group_item_lot_proposal1) do
      lot_proposal1.lot_group_item_lot_proposals.first
    end

    let(:lot_group_item_lot_proposal2) do
      lot_proposal2.lot_group_item_lot_proposals.first
    end

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
      it { expect(report.url).to match /storage\/fornecedores_licitacao_.*\.xls$/ }
      it { expect(report.error_message).to be_nil }
      it { expect(report.error_backtrace).to be_nil }
      it { expect(file_xlsx).to be_present }

      it { expect(sheet.row(2)[0]).to eq provider1.document }
      it { expect(sheet.row(2)[1]).to eq provider1.name }
      it { expect(sheet.row(2)[2]).to eq 2 }

      it { expect(sheet.row(3)[0]).to eq provider2.document }
      it { expect(sheet.row(3)[1]).to eq provider2.name }
      it { expect(sheet.row(3)[2]).to eq 1 }

      it { expect(sheet1.row(1)[0]).to eq bidding1.title }
      it { expect(sheet1.row(1)[1]).to eq provider1.name }
      it { expect(sheet1.row(1)[2]).to eq provider1.document }
      it { expect(sheet1.row(1)[3]).to eq provider1.address.city.name }
      it { expect(sheet1.row(1)[4]).to eq bidding1.cooperative.name }
      it { expect(sheet1.row(1)[5]).to eq bidding1.cooperative.cnpj }
      it { expect(sheet1.row(1)[6]).to eq bidding1.cooperative.address.city.name }
      it { expect(sheet1.row(1)[7]).to eq I18n.t("services.download.supplier.biddings.kind.#{bidding1.kind}") }
      it { expect(sheet1.row(1)[8]).to eq I18n.t("services.download.supplier.biddings.modality.#{bidding1.modality}") }
      it { expect(sheet1.row(1)[9]).to eq I18n.t("services.download.supplier.biddings.#{bidding1.status}") }
      it { expect(sheet1.row(1)[10]).to eq I18n.l(bidding1.start_date) }
      it { expect(sheet1.row(1)[11]).to eq I18n.l(bidding1.closing_date) }

      it { expect(sheet1.row(2)[0]).to eq bidding2.title }
      it { expect(sheet1.row(2)[1]).to eq provider1.name }
      it { expect(sheet1.row(2)[2]).to eq provider1.document }
      it { expect(sheet1.row(2)[3]).to eq provider1.address.city.name }
      it { expect(sheet1.row(2)[4]).to eq bidding2.cooperative.name }
      it { expect(sheet1.row(2)[5]).to eq bidding2.cooperative.cnpj }
      it { expect(sheet1.row(2)[6]).to eq bidding2.cooperative.address.city.name }
      it { expect(sheet1.row(2)[7]).to eq I18n.t("services.download.supplier.biddings.kind.#{bidding2.kind}") }
      it { expect(sheet1.row(2)[8]).to eq I18n.t("services.download.supplier.biddings.modality.#{bidding2.modality}") }
      it { expect(sheet1.row(2)[9]).to eq I18n.t("services.download.supplier.biddings.#{bidding2.status}") }
      it { expect(sheet1.row(2)[10]).to eq I18n.l(bidding2.start_date) }
      it { expect(sheet1.row(2)[11]).to eq I18n.l(bidding2.closing_date) }

      it { expect(sheet1.row(3)[0]).to eq bidding2.title }
      it { expect(sheet1.row(3)[1]).to eq provider2.name }
      it { expect(sheet1.row(3)[2]).to eq provider2.document }
      it { expect(sheet1.row(3)[3]).to eq provider2.address.city.name }
      it { expect(sheet1.row(3)[4]).to eq bidding2.cooperative.name }
      it { expect(sheet1.row(3)[5]).to eq bidding2.cooperative.cnpj }
      it { expect(sheet1.row(3)[6]).to eq bidding2.cooperative.address.city.name }
      it { expect(sheet1.row(3)[7]).to eq I18n.t("services.download.supplier.biddings.kind.#{bidding2.kind}") }
      it { expect(sheet1.row(3)[8]).to eq I18n.t("services.download.supplier.biddings.modality.#{bidding2.modality}") }
      it { expect(sheet1.row(3)[9]).to eq I18n.t("services.download.supplier.biddings.#{bidding2.status}") }
      it { expect(sheet1.row(3)[10]).to eq I18n.l(bidding2.start_date) }
      it { expect(sheet1.row(3)[11]).to eq I18n.l(bidding2.closing_date) }
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
