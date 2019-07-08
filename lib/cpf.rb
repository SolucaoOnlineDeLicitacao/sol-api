# based on: https://gist.github.com/bpinto/2920803
# based on: https://github.com/sobrinho/cpf_validator
module CPF
  extend self # to allow using private methods! (module_function will not allow it)

  def generate
    number = Array.new(9) { rand(9) }
    2.times { number << verification_digit_for(number) }

    mask(number.join)
  end

  def mask(number)
    cpf = number.to_s

    unless masked?(cpf)
      cpf = unmask(cpf)
      cpf = cpf.gsub(/^(\d{3})(\d{3})(\d{3})(\d{2})$/, "\\1.\\2.\\3-\\4")
    end

    cpf
  end

  def masked?(number)
    number =~ /^\d{3}\.\d{3}\.\d{3}-\d{2}$/
  end

  def unmask(string)
    cpf = string.to_s
    cpf.gsub(/\D/, '').rjust(11, "0")
  end

  def valid?(number)
    masked?(number) && !black_listed?(number) && digits_matches?(number)
  end


  private

  # ignore same digit numbers
  def black_listed?(number)
    unmask(number) =~ /^12345678909|(\d)\1{10}$/
  end

  def digit_matches?(number, digit)
    sum = 0
    digits = number.to_s.scan(/\d/).map(&:to_i)

    digit.times do |idx|
      sum += digits[idx] * (digit + 1 - idx)
    end

    result = sum % 11
    result = result < 2 ? 0 : 11 - result

    result == digits[digit]
  end

  def digits_matches?(number)
    digit_matches?(number, 9) && digit_matches?(number, 10)
  end

  def verification_digit_for(number)
    idx = 1
    sums = number.reverse.collect do |digit|
      idx += 1
      digit * idx
    end

    verification_digit = 11 - sums.inject(0) { |sum, item| sum + item } % 11
    verification_digit < 10 ? verification_digit : 0
  end

end
