module PhoneNumber
  extend self # to allow using private methods! (module_function will not allow it)

  TYPES = %i[cell_phone landline]
  PHONE_REGEXP = /\A\([1-9]{2}\) [2-9][0-9]{3,4}\-[0-9]{4}\z/ # landline or cell phone
  CELL_PHONE_REGEXP = /\A\([1-9]{2}\) 9[0-9]{4}\-[0-9]{4}\z/ # (99) 99999-9999
  LANDLINE_PHONE_REGEXP = /\A\([1-9]{2}\) [2-9][0-9]{3}\-[0-9]{4}\z/ # (99) 9999-9999

  def generate(type: nil)
    type ||= TYPES.sample

    send "generate_#{type}"
  end

  def generate_cell_phone
    "(#{rand(1..9)}#{rand(1..9)}) #{rand(90000..99999)}-#{rand(1000..9999)}"
  end

  def generate_landline
    "(#{rand(1..9)}#{rand(1..9)}) #{rand(2000..9999)}-#{rand(1000..9999)}"
  end

  def mask(number)
    phone = number.to_s

    return unless phone.present?

    unless masked?(phone)
      digits = unmask(phone)

      phone = case digits.length
              when 11 then "(#{digits[0..1]}) #{digits[2..6]}-#{digits[7..10]}" # cell phone
              when 10 then "(#{digits[0..1]}) #{digits[2..5]}-#{digits[6..9]}"
              else nil
              end
    end

    phone
  end

  def masked?(number)
    number =~ PHONE_REGEXP
  end

  def unmask(string)
    phone = string.to_s
    phone.gsub(/\D/, '')
  end

  def valid?(number)
    masked?(number) && !black_listed?(number)
  end

  def type(number)
    return unless valid? number
    case number
    when CELL_PHONE_REGEXP then :cell_phone
    when LANDLINE_PHONE_REGEXP then :landline
    end
  end

  private

  # ignore some black listed phones
  def black_listed?(number)
    false
  end
end
