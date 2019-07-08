module Validators
  module Test
    module Matchers

      #
      # Validação para valor de Latitude em atributos
      #
      module ValidateLatitudeFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o valor de latitude
        #
        # Uso:
        # ```
        # it { is_expected.to validate_latitude_for(:lat) }
        # ```
        matcher :validate_latitude_for do |attribute|
          match do |record|
            expect(record).to validate_numericality_of(attribute)
              .is_greater_than_or_equal_to(-90)
              .is_less_than_or_equal_to(90)
          end
        end

      end

    end
  end
end
