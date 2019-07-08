class PhoneValidator < ActiveModel::EachValidator
  PHONE_REGEXP = /\A\([1-9]{2}\) [2-9][0-9]{3,4}\-[0-9]{4}\z/ # landline or cell phone

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless value.to_s.match? PHONE_REGEXP
  end
end
