require 'rails_helper'

RSpec.describe ReportsService::Items::Prices::Download, type: :service do
  let(:report) { create(:report, report_type: :items) }
  let(:service_call) { described_class.call(report: report) }

  describe '.call' do
    let(:covenant) { create(:covenant) }
    let(:bidding) do
      create(:bidding, status: :draft, kind: 2, covenant: covenant, build_lot: false)
    end

    let!(:provider_1) { create(:provider) }
    let!(:provider_2) { create(:provider) }
    let!(:provider_3) { create(:provider) }

    let!(:supplier1) { create(:supplier, provider: provider_1) }
    let!(:supplier2) { create(:supplier, provider: provider_2) }
    let!(:supplier3) { create(:supplier, provider: provider_3) }

    let(:item1) do
      create(:item, title: "Telha metálica trapezoidal",
        description: "Fornecimento de telhas metálica trapezoidal")
    end

    let(:item2) do
      create(:item, title: "Regador de plástico 5 Litros",
        description: "Regador de plástico capacidade 5 Litros")
    end

    let(:item3) do
      create(:item, title: "Regador de plástico 15 Litros",
        description: "Regador de plástico capacidade 15 Litros")
    end

    let(:group) do
      group = Group.new(covenant: covenant); group.save(validate: false);
      group
    end

    let(:group_item1) { create(:group_item, group: group, item: item1) }
    let(:group_item2) { create(:group_item, group: group, item: item2) }
    let(:group_item3) { create(:group_item, group: group, item: item3) }

    let!(:lot1) do
      lot = Lot.new(id: 1, bidding: bidding, name: 'Lote A'); lot.save(validate: false); lot
    end

    let!(:lot2) do
      lot = Lot.new(id: 2, bidding: bidding, name: 'Lote B'); lot.save(validate: false); lot
    end

    let!(:lot3) do
      lot = Lot.new(id: 3, bidding: bidding, name: 'Lote C'); lot.save(validate: false); lot
    end

    let!(:lot_group_item1) do
      create(:lot_group_item, id: 1, lot: lot1, group_item: group_item1)
    end

    let!(:lot_group_item2) do
      create(:lot_group_item, id: 2, lot: lot2, group_item: group_item2)
    end

    let!(:lot_group_item3) do
      create(:lot_group_item, id: 3, lot: lot3, group_item: group_item3)
    end

    let!(:proposal1) do
      create(:proposal, provider: provider_1, bidding: bidding, status: :accepted)
    end

    let!(:proposal2) do
      create(:proposal, provider: provider_2, bidding: bidding, status: :accepted)
    end

    let!(:proposal3) do
      create(:proposal, provider: provider_3, bidding: bidding, status: :accepted)
    end

    let!(:lot_proposal1) do
      create(:lot_proposal, lot: lot1, proposal: proposal1, supplier: supplier1)
    end

    let!(:lot_proposal2) do
      create(:lot_proposal, lot: lot2, proposal: proposal2, supplier: supplier1)
    end

    let!(:lot_proposal3) do
      create(:lot_proposal, lot: lot3, proposal: proposal3, supplier: supplier3)
    end

    let!(:bidding_finnished) { bidding.finnished! }
    let(:date_time) { DateTime.new(2015, 7, 19, 13, 40) }
    let(:file_xlsx) { Spreadsheet.open Dir[report.url].first }
    let(:sheet) { file_xlsx.worksheet 0 }

    before do
      group_item1.accepted_lot_group_item_lot_proposals.each_with_index do |lot_group_item_lot_proposal, new_price|
        lot_group_item_lot_proposal.update!(price: new_price + 1)
      end
      group_item2.accepted_lot_group_item_lot_proposals.each_with_index do |lot_group_item_lot_proposal, new_price|
        lot_group_item_lot_proposal.update!(price: new_price + 10)
      end

      group_item3.accepted_lot_group_item_lot_proposals.each_with_index do |lot_group_item_lot_proposal, new_price|
        lot_group_item_lot_proposal.update!(price: new_price + 20)
      end

      @group_item1_accepted = group_item1.accepted_lot_group_item_lot_proposals.map do |item|
        ActionController::Base.helpers.number_to_currency(item.price)
      end

      @group_item2_accepted = group_item2.accepted_lot_group_item_lot_proposals.map do |item|
        ActionController::Base.helpers.number_to_currency(item.price)
      end

      @group_item3_accepted = group_item3.accepted_lot_group_item_lot_proposals.map do |item|
        ActionController::Base.helpers.number_to_currency(item.price)
      end

    end

    context 'when it runs successfully' do
      before do
        allow(DateTime).to receive(:current).and_return(date_time)
        service_call
      end

      it { expect(report.success?).to be_truthy }
      it { expect(report.url).to match /storage\/variacao_preco_itens_.*\.xls$/ }
      it { expect(report.error_message).to be_nil }
      it { expect(report.error_backtrace).to be_nil }
      it { expect(file_xlsx).to be_present }

      context 'line 2' do
        it { expect(sheet.row(2)[0]).to eq item1.title }
        it { expect(sheet.row(2)[1]).to eq lot1.name }
        it { expect(@group_item1_accepted).to include sheet.row(2)[2] }
        it { expect(sheet.row(2)[3]).to eq bidding.title }
        it { expect(sheet.row(2)[4]).to eq provider_1.name }
        it { expect(sheet.row(2)[5]).to eq provider_1.document }
        it { expect(sheet.row(2)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(2)[7]).to eq bidding.cooperative.cnpj }
      end

      context 'line 3' do
        it { expect(sheet.row(3)[0]).to eq item1.title }
        it { expect(sheet.row(3)[1]).to eq lot1.name }
        it { expect(@group_item2_accepted).to include sheet.row(3)[2] }
        it { expect(sheet.row(3)[3]).to eq bidding.title }
        it { expect(sheet.row(3)[4]).to eq provider_2.name }
        it { expect(sheet.row(3)[5]).to eq provider_2.document }
        it { expect(sheet.row(3)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(3)[7]).to eq bidding.cooperative.cnpj }
      end

      context 'line 4' do
        it { expect(sheet.row(4)[0]).to eq item1.title }
        it { expect(sheet.row(4)[1]).to eq lot1.name }
        it { expect(@group_item3_accepted).to include sheet.row(4)[2] }
        it { expect(sheet.row(4)[3]).to eq bidding.title }
        it { expect(sheet.row(4)[4]).to eq provider_3.name }
        it { expect(sheet.row(4)[5]).to eq provider_3.document }
        it { expect(sheet.row(4)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(4)[7]).to eq bidding.cooperative.cnpj }
      end

      context 'line 5' do
        it { expect(sheet.row(5)[0]).to eq item1.title }
        it { expect(sheet.row(5)[1]).to eq lot1.name }
        it { expect(@group_item1_accepted).to include sheet.row(5)[2] }
        it { expect(sheet.row(5)[3]).to eq bidding.title }
        it { expect(sheet.row(5)[4]).to eq provider_1.name }
        it { expect(sheet.row(5)[5]).to eq provider_1.document }
        it { expect(sheet.row(5)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(5)[7]).to eq bidding.cooperative.cnpj }
      end

      context 'line 6' do
        it { expect(sheet.row(6)[0]).to eq item2.title }
        it { expect(sheet.row(6)[1]).to eq lot2.name }
        it { expect(@group_item2_accepted).to include sheet.row(6)[2] }
        it { expect(sheet.row(6)[3]).to eq bidding.title }
        it { expect(sheet.row(6)[4]).to eq provider_2.name }
        it { expect(sheet.row(6)[5]).to eq provider_2.document }
        it { expect(sheet.row(6)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(6)[7]).to eq bidding.cooperative.cnpj }
      end

      context 'line 7' do
        it { expect(sheet.row(7)[0]).to eq item3.title }
        it { expect(sheet.row(7)[1]).to eq lot3.name }
        it { expect(@group_item3_accepted).to include sheet.row(7)[2] }
        it { expect(sheet.row(7)[3]).to eq bidding.title }
        it { expect(sheet.row(7)[4]).to eq provider_3.name }
        it { expect(sheet.row(7)[5]).to eq provider_3.document }
        it { expect(sheet.row(7)[6]).to eq bidding.cooperative.name }
        it { expect(sheet.row(7)[7]).to eq bidding.cooperative.cnpj }
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
