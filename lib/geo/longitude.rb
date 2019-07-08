module Geo
  #
  # Coordenada geográfica de longitude
  #
  class Longitude
    MAX =  180
    MIN = -180

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
