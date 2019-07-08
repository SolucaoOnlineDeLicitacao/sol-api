class ApplicationMailer < ActionMailer::Base
  # add_template_helper ApplicationHelper

  default from: Rails.application.secrets.dig(:action_mailer, :default_options, :from)
  layout 'mailer'
end
