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
