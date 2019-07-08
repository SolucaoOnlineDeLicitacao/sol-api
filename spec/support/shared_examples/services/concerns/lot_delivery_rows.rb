RSpec.shared_examples 'services/concerns/lot_delivery_rows' do
  context 'and is the first row' do
    let(:deadline) { lot.deadline || lot.bidding.deadline }
    let(:days_deadline) do
      I18n.t('services.biddings.download.header.delivery.rows.deadline') % deadline
    end

    it { expect(sheet_cell(2, 0)).to eq lot.id }
    it { expect(sheet_cell(2, 1)).to eq lot.name }
    it { expect(sheet_cell(2, 2)).to eq days_deadline }
    it { expect(sheet_cell(2, 3)).to eq address }
  end

  context 'and is the second row' do
    it { expect(sheet_row(3)).to be_empty }
  end
end
