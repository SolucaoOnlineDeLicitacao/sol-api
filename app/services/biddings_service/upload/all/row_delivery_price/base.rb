module BiddingsService::Upload::All::RowDeliveryPrice
  class Base
    include Call::Methods

    LOT_COLUMN = :first
    FROM_LINE_THREE = 2
    TO_END = -1
    DELIVERY_PRICE_INDEX = 4

    def main_method
      get_delivery_price
    end

    private

    def get_delivery_price
      convert_value(lot_line[DELIVERY_PRICE_INDEX])
    end

    def lot_line
      all_rows.group_by(&LOT_COLUMN).
        select{ |row_lot_id| lot.id == row_lot_id.to_i }.
        values.flatten
    end

    def convert_value(value)
      return if value.blank?
      value.to_s.gsub(/[^(0-9|\.|\,)]/, '').gsub('.', '').gsub(',','.').to_f
    end
  end
end
