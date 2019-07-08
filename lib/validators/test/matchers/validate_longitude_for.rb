module Validators
  module Test
    module Matchers

      #
      # Validação para valor de Longitude em atributos
      #
      module ValidateLongitudeFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o valor de longitude
        #
        # Uso:
        # ```
        # it { is_expected.to validate_longitude_for(:lng) }
        # ```
        matcher :validate_longitude_for do |attribute|
          match do |record|
            expect(record).to validate_numericality_of(attribute)
              .is_greater_than_or_equal_to(-180)
              .is_less_than_or_equal_to(180)
          end
        end

      end

    end
  end
end
