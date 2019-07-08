module Validators
  module Test
    module Matchers

      #
      # Validação para atributos em formato de e-mail
      #
      module ValidateEmailFor
        extend RSpec::Matchers::DSL

        #
        # RSpec matcher para verificar o casting de tipo de atributos
        #
        # Uso:
        # ```
        # it { is_expected.to validate_email_for(:email) }
        # it { is_expected.to validate_email_for(:owner_email) }
        # ```
        matcher :validate_email_for do |attribute|
          match do |record|
            expect(record).to allow_values(*%w[
              test@example.com
              test.some@example.com
              test+some@example.com
            ]).for(attribute)

            expect(record).not_to allow_values(*%w[
              invalid
            ]).for(attribute)
          end
        end

      end

    end
  end
end
