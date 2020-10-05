RSpec.shared_examples 'services/concerns/download_asserts' do |proposal, file_type|
  let(:file_name) { I18n.t('services.biddings.download.file_name') }
  let(:lot) { create(:lot) }
  let(:another_lot) { create(:lot) }
  let(:bidding) { create(:bidding, build_lot: false, lots: [lot, another_lot]) }
  let(:book_instance) do
    if file_type == 'xls'
      Spreadsheet::Write::Xls
    else
      Spreadsheet::Write::Xlsx
    end
  end
  let(:base_params) { { bidding: bidding, file_type: file_type } }
  let(:proposal_lot?) { proposal == 'lot' }
  let(:params) { proposal_lot? ? base_params.merge(lot: lot) : base_params }
  let(:path) do
    "storage/**/#{file_name}_#{fix_value}_#{date_time.strftime('%d%m%Y%H%M%S')}"
  end
  let(:date_time) { DateTime.new(2015, 7, 19, 13, 40, 00) }
  let(:fix_value) { 12345 }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.file_type).to eq(file_type) }
    it { expect(subject.bidding).to eq(bidding) }
    it { expect(subject.lot).to eq(lot) if proposal_lot? }
    it { expect(subject.book).to be_an_instance_of(book_instance) }
  end

  describe '.call' do
    subject { described_class.call(params) }

    it { is_expected.to match /storage\/#{file_name}_/ }
    it { expect(file).to be_present }

    describe 'sheet one' do
      let(:sheet_number) { 0 }

      context 'when validating the header title' do
        let(:header_title) do
          I18n.t("services.biddings.download.header.price.title").first
        end

        it { expect(sheet_cell(0, 0)).to eq(header_title) }
      end

      context 'when validating the header' do
        let(:header_columns) do
          I18n.t("services.biddings.download.header.price.columns")
        end

        it 'the header columns values' do
          header_columns.each_with_index do |expected, i|
            expect(sheet_cell(1, i)).to eq(expected)
          end
        end
      end

      context 'when validating the row' do
        include_examples "services/concerns/lot_rows" if proposal == 'lot'
        include_examples "services/concerns/all_rows" if proposal == 'all'
      end
    end

    describe 'sheet two' do
      let(:sheet_number) { 1 }

      context 'when validating the header title' do
        let(:header_title) do
          I18n.t("services.biddings.download.header.delivery.title").first
        end

        it { expect(sheet_cell(0, 0)).to eq(header_title) }
      end

      context 'when validating the header' do
        let(:header_columns) do
          I18n.t("services.biddings.download.header.delivery.columns")
        end

        it 'the header columns values' do
          header_columns.each_with_index do |expected, i|
            expect(sheet_cell(1, i)).to eq(expected)
          end
        end
      end

      context 'when validating the row' do
        context 'when the lot has an address' do
          let(:address) { lot.address }
          let(:another_address) { another_lot.address }

          include_examples "services/concerns/lot_delivery_rows" if proposal == 'lot'
          include_examples "services/concerns/all_delivery_rows" if proposal == 'all'
        end

        context 'when the lot hasnt an address' do
          let(:address) { lot.bidding.address }
          let(:another_address) { another_lot.bidding.address }

          before do
            lot.update_attributes(address: '')
            another_lot.update_attributes(address: '')
          end

          include_examples "services/concerns/lot_delivery_rows" if proposal == 'lot'
          include_examples "services/concerns/all_delivery_rows" if proposal == 'all'
        end
      end
    end
  end
end
