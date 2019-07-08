#
# Validações de CEP (BR).
# Veja regras em http://www.geradordecep.com.br.
#
class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEXP = /\A\d{5}-\d{3}\z/ # 99999-999

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :invalid) unless value.to_s.match? ZIP_CODE_REGEXP
  end
end
