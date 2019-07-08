module Validators
  module Test
    module Matchers

      #
      # Validação para número de telefone celular (BR) em atributos
      #
      module ValidateCellPhoneFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_cell_phone_for(:phone) }
        # it { is_expected.to validate_cell_phone_for(:owner_phone) }
        # ```
        matcher :validate_cell_phone_for do |attribute|
          match do |record|
            expect(record).to allow_values(
              '(19) 99999-9999',
              '(11) 98999-9999',
              '(11) 97999-9999'
            ).for(attribute)

            expect(record).not_to allow_values(
              '(11) 1111-1111',
              '(11) 19999-9999',
              '(11) 999999-1111',
              '(11) 11111-111',
              '(11) 99999-999',
              '(111) 99999-9999',
              '(112) 3333-1111',
              'invalid'
            ).for(attribute)
          end
        end

      end

    end
  end
end
