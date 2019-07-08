class CellPhoneValidator < ActiveModel::EachValidator
  CELL_PHONE_REGEXP = /\A\([1-9]{2}\) 9[0-9]{4}\-[0-9]{4}\z/ # (99) 99999-9999

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless value.to_s.match? CELL_PHONE_REGEXP
  end
end
