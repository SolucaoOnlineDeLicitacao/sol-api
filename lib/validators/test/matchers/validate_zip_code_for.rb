module Validators
  module Test
    module Matchers

      #
      # Validação para CEP em atributos
      #
      module ValidateZipCodeFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para validar CEP
        #
        # Uso:
        # ```
        # it { is_expected.to validate_zip_code_for(:zip_code) }
        # it { is_expected.to validate_zip_code_for(:residential_zip_code) }
        # ```
        matcher :validate_zip_code_for do |attribute|
          match do |record|
            expect(record).to allow_values(
              '13500-000',
              '01310-000',
              '13020-110'
            ).for(attribute)

            expect(record).not_to allow_values(
              '13500000',
              '01310000',
              '13020110',
              '1350-0000',
              '01310 000',
              '130101-110',
              '13-500-000'
            ).for(attribute)
          end
        end

      end

    end
  end
end
