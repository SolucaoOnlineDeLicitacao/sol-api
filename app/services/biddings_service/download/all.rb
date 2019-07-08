module BiddingsService::Download
  class All < Base
    def iterate_and_fill_rows
      row_base = 0

      bidding.lots.each_with_index do |lot, lot_index|
        fill_row('delivery', lot_index, lot)

        lot.lot_group_items.each_with_index do |lot_group_item, row_index|
          fill_row('price', row_base + row_index, lot, lot_group_item)
        end

        row_base += lot.lot_group_items_count
      end
    end
  end
end
