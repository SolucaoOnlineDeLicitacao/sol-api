class LandlinePhoneValidator < ActiveModel::EachValidator
  LANDLINE_PHONE_REGEXP = /\A\([1-9]{2}\) [2-9][0-9]{3}\-[0-9]{4}\z/ # (99) 9999-9999

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless value.to_s.match? LANDLINE_PHONE_REGEXP
  end
end
