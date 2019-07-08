class CNPJValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless CNPJ.valid?(value)
  end
end
