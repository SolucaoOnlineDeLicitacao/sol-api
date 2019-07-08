module Validators
  module Test
    module Matchers

      #
      # Validação para CNPJ em atributos
      #
      module ValidateCNPJFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_cnpj_for(:cnpj) }
        # it { is_expected.to validate_cnpj_for(:owner_cnpj) }
        # ```
        matcher :validate_cnpj_for do |attribute|
          match do |record|
            expect(record).to allow_values(*%w[
              17.112.251/0001-60
              99.211.946/0001-64
              31.925.110/0001-98
            ]).for(attribute)

            expect(record).not_to allow_values(*%w[
              40.081.340/5124-62
              04.081.340/5074-52
              11.111.111/1111-11
              00.000.000/0000-00
              invalid
            ]).for(attribute)
          end
        end

      end

    end
  end
end
