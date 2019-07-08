module Validators
  module Test
    module Matchers

      #
      # Validação para sintaxe cron em atributos
      #
      module ValidateCronSyntaxFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para validar sintaxe cron
        #
        # Uso:
        # ```
        # it { is_expected.to validate_cron_syntax_for(:schedule) }
        # ```
        matcher :validate_cron_syntax_for do |attribute|
          match do |record|
            expect(record).to allow_values(
              '0 14 * * *',
              '0 8 * * 0',
              '0 2 5 * *'
            ).for(attribute)

            expect(record).not_to allow_values(
              '0 2 5 * * *',
              '0 A 5 * *',
              '0 2 5',
              '0 0 0 0 0 0 0'
            ).for(attribute)
          end
        end

      end

    end
  end
end
