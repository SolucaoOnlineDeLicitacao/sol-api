module CNPJ
  extend self # to allow using private methods! (module_function will not allow it)

  def generate
    number = Array.new(12) { [*0..9].sample }
    2.times { number << verification_digit_for(number) }

    mask(number.join)
  end

  def mask(number)
    cnpj = number.to_s

    unless masked?(cnpj)
      cnpj = unmask(cnpj)
      cnpj = cnpj.gsub(/\A(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})\Z/, "\\1.\\2.\\3/\\4-\\5")
    end

    cnpj
  end

  def masked?(cnpj)
    cnpj =~ /^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$/
  end

  def unmask(string)
    cnpj = string.to_s
    cnpj.gsub(/\D/, '').rjust(14, "0")
  end

  def valid?(number)
    masked?(number) && !black_listed?(number) && digits_matches?(number)
  end

  private

  # ignore same digit numbers
  def black_listed?(number)
    unmask(number) =~  /^(\d)\1{13}$/
  end

  def digits_matches?(number)
    digit_matches?(number, 12) && digit_matches?(number, 13)
  end

  def digit_matches?(number, digit)
    number = unmask(number)
    factor = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    factor.unshift 6 if digit == 13

    sum = 0

    digit.times do |i|
      sum += number[i].to_i * factor[i]
    end

    result = sum % 11
    result = result < 2 ? 0 : 11 - result

    result == number[digit].to_i
  end

  def verification_digit_for(numbers)
    index = 2

    sum = numbers.reverse.reduce(0) do |buffer, number|
      (buffer + number * index).tap do
        index = index == 9 ? 2 : index + 1
      end
    end

    mod = sum % 11
    mod < 2 ? 0 : 11 - mod
  end

end
