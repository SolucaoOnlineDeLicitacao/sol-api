Rails.application.config.before_initialize do
  action_mailer_config = Rails.application.config.action_mailer
  options = Rails.application.secrets.action_mailer

  # default options
  default_options = options.fetch(:default_options, {})
  action_mailer_config.default_options ||= {} # ensuring it exists
  action_mailer_config.default_options.merge! default_options
  # XXX é necessário definir essas opções também no ActionMailer::Base, pois as configurações
  # em Rails.application.config.action_mailer, nesse momento (initializer), não são mais definidas
  # no ActionMailer::Base
  # @see https://github.com/eval/envied/issues/8
  #      https://stackoverflow.com/a/14347449
  ActionMailer::Base.default_options = action_mailer_config.default_options

  # specifies the queue name for mailers. By default this is mailers.
  # action_mailer_config.deliver_later_queue_name = :mailers

  # url options
  # these are set in `initializers/routes.rb`, using Rails.application.routes.default_url_options

  # delivery_method and settings (e.g. :smtp and .smtp_settings)
  if Rails.env.production?
    delivery_method = options.fetch(:delivery_method, :smtp).to_sym # XXX precisa ser Symbol!
    action_mailer_config.delivery_method = delivery_method
    ActionMailer::Base.delivery_method = delivery_method

    case delivery_method
    when :mailgun then
      action_mailer_config.mailgun_settings ||= {}
      action_mailer_config.mailgun_settings.merge! options[:mailgun_settings]
      ActionMailer::Base.mailgun_settings = action_mailer_config.mailgun_settings
    when :smtp # or sendgrig using smtp relay
      action_mailer_config.smtp_settings ||= {}
      action_mailer_config.smtp_settings.merge! options[:smtp_settings]
      ActionMailer::Base.smtp_settings = action_mailer_config.smtp_settings
    end
  end
end
