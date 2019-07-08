module Geo
  #
  # Coordenada geográfica de latitude
  #
  class Latitude
    MAX =  90
    MIN = -90

    def self.rand
      signal = [-1, 1].sample
      value = ::Kernel.rand(MAX + 1)
      value += ::Kernel.rand if value < MAX

      signal * value
    end

    def self.valid?(value)
      value.present? and value.is_a?(Numeric) and value.between?(MIN, MAX)
    end
  end
end
