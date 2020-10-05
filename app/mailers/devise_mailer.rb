#
# Mailer básico para o Devise, com configuração no initializer.
#
class DeviseMailer < Devise::Mailer
  layout 'mailer'

  def reset_password_instructions(record, token, opts={})
    I18n.with_locale(record.locale) do
      super
    end
  end
end
