module Validators
  module Test
    module Matchers

      #
      # Validação para CPF em atributos
      #
      module ValidateCPFFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_cpf_for(:cpf) }
        # it { is_expected.to validate_cpf_for(:owner_cpf) }
        # ```
        matcher :validate_cpf_for do |attribute|
          match do |record|
            expect(record).to allow_values(*%w[
              853.249.498-68
              229.141.168-37
              013.268.579-59
            ]).for(attribute)

            expect(record).not_to allow_values(*%w[
              853.249.498-61
              229.141.168-32
              013.268.579-53
              111.111.111-11
              333.333.333-33
              invalid
            ]).for(attribute)
          end
        end

      end

    end
  end
end
