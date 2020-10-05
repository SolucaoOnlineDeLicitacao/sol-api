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

      I18n.with_locale(I18n.default_locale) do
        value.to_s.
          gsub(/[^(0-9|\"#{delimiter}"|\"#{separator}")]/, '').
          gsub(delimiter, '').
          gsub(separator, ".").
          to_f
      end
    end

    def delimiter
      @delimiter ||= I18n.t('number.currency.format.delimiter')
    end

    def separator
      @separator ||= I18n.t('number.currency.format.separator')
    end
  end
end
