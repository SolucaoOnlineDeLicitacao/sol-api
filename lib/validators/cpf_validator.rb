# based on: https://github.com/sobrinho/cpf_validator
class CPFValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless CPF.valid?(value)
  end
end
