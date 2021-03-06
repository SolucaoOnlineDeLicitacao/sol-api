module Validators
  module Test
    module Matchers

      #
      # Validação para número de telefone fixo (BR) em atributos
      #
      module ValidateLandlinePhoneFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_landline_phone_for(:phone) }
        # it { is_expected.to validate_landline_phone_for(:owner_phone) }
        # ```
        matcher :validate_landline_phone_for do |attribute|
          match do |record|
            expect(record).to allow_values(
              '(19) 2111-1111',
              '(11) 3323-3323',
              '(11) 9999-9999'
            ).for(attribute)

            expect(record).not_to allow_values(
              '(11) 1111-9999',
              '(11) 19999-9999',
              '(11) 99999-1111',
              '(11) 3323-111',
              '(11) 33232-999',
              '(111) 3323-9999',
              '(112) 99999-1111',
              'invalid'
            ).for(attribute)
          end
        end

      end

    end
  end
end
