module Validators
  module Test
    module Matchers

      #
      # Validação para valores booleanos [true, false] em atributos
      #
      module ValidateBooleanFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar a validação de valores booleanos em atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_boolean_for(:admin) }
        # it { is_expected.to validate_boolean_for(:confirmed) }
        # ```
        matcher :validate_boolean_for do |attribute|
          match do |record|
            # XXX isso gera um warning do shoulda-matchers. Mas é a solução apoiada pelo Rails
            # para validação de boolean - inclusive está na documentação.
            # @see https://github.com/thoughtbot/shoulda-matchers/issues/761#issuecomment-254690316
            # @see https://github.com/thoughtbot/shoulda-matchers/issues/922#issuecomment-226812167
            expect(record).to validate_inclusion_of(attribute).in_array([true, false])
          end
        end

      end

    end
  end
end
