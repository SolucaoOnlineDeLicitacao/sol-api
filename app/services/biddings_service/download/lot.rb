module BiddingsService::Download
  class Lot < Base
    def iterate_and_fill_rows
      fill_row('delivery', 0, lot)

      lot.lot_group_items.each_with_index do |lot_group_item, row_index|
        fill_row('price', row_index, lot, lot_group_item)
      end
    end
  end
end
