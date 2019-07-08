#
# Mailer básico para o Devise, com configuração no initializer.
#
class DeviseMailer < Devise::Mailer
  layout 'mailer'
end
