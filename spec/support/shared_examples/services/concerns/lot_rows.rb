RSpec.shared_examples 'services/concerns/lot_rows' do
  include ActionView::Helpers::NumberHelper

  context 'and is the first row' do
    let(:unit) do
      lot.lot_group_items.first.group_item.item.unit_name
    end
    
    it { expect(sheet_cell(2, 0)).to eq bidding.id }
    it { expect(sheet_cell(2, 1)).to eq lot.id }
    it { expect(sheet_cell(2, 2)).to eq lot.name }
    it { expect(sheet_cell(2, 3)).to eq lot.lot_group_items.first.id }
    it { expect(sheet_cell(2, 4)).to eq lot.lot_group_items.first.group_item.item.classification.name }
    it { expect(sheet_cell(2, 5)).to eq lot.lot_group_items.first.group_item.item.description }
    it { expect(sheet_cell(2, 6)).to eq unit }
    it { expect(sheet_cell(2, 7)).to eq number_with_delimiter(lot.lot_group_items.first.quantity) }
  end

  context 'and is the second row' do
    it { expect(sheet_row(3)).to be_empty }
  end
end
