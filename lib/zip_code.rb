#
# Módulo auxiliar para geração e validação de CEP.
#
module ZipCode
  extend self # to allow using private methods! (module_function will not allow it)

  ZIP_CODE_REGEXP = /\A\d{5}-\d{3}\z/ # 99999-999

  def generate
    first_part = rand(99999).to_s.rjust(5, '0')
    second_part = rand(999).to_s.rjust(3, '0')

    "#{first_part}-#{second_part}"
  end


  def mask(string)
    zip_code = string.to_s

    unless masked?(zip_code)
      digits = unmask(zip_code)

      zip_code = "#{digits[0..4]}-#{digits[5..7]}"
    end

    zip_code
  end

  def masked?(string)
    string.match? ZIP_CODE_REGEXP
  end

  def unmask(string)
    zip_code = string.to_s
    zip_code.gsub(/\D/, '')
  end

  def valid?(string)
    masked?(string) && !black_listed?(string)
  end

  private

  # ignore some black listed values
  def black_listed?(string)
    false
  end
end
