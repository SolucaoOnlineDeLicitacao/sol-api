module Pdf
  module HelperMethods
    def valid_value_for_full_text?(value)
      value >= 1 && value <= 999999999
    end
  end
end
