module Validators
  module Test
    module Matchers

      #
      # Validação para número de telefone (fixo ou celular) (BR) em atributos
      #
      module ValidatePhoneFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_phone_for(:phone) }
        # it { is_expected.to validate_phone_for(:owner_phone) }
        # ```
        matcher :validate_phone_for do |attribute|
          match do |record|
            expect(record).to allow_values(
              '(11) 2222-2222',
              '(19) 99999-9999'
            ).for(attribute)

            expect(record).not_to allow_values(
              '(11) 1111-1111',
              '(11) 19999-9999',
              '(112) 1111-1111',
              '(112) 111111-1111',
              '(112) 111111-111',
              'invalid'
            ).for(attribute)
          end
        end

      end

    end
  end
end
