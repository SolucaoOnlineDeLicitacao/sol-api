module BiddingsService::Upload::All::RowValues
  module BaseRowValues
    attr_reader :lot_group_item_id, :price

    LOT_GROUP_ITEM_ID_INDEX = 3
    PRICE_INDEX = 8

    def initialize(row)
      @lot_group_item_id = row[LOT_GROUP_ITEM_ID_INDEX].to_i
      @price = convert_value(row[PRICE_INDEX])
    end

    private

    def convert_value(value)
      return if value.blank?
      value.to_s.gsub(/[^(0-9|\.|\,)]/, '').gsub('.', '').gsub(',','.').to_f
    end
  end
end
