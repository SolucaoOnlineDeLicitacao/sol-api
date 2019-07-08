# Setting default url options for any route generator (controller, mailer, url_helpers, ...)
# https://stackoverflow.com/a/36792962
#
# NOTE: if you're using Capybara, make sure you override it with Capybara.current_session.server
# data - checkout `spec/support/capybara.rb` for details.
Rails.application.config.before_initialize do
  default_url_options = Rails.application.secrets.dig(:routes, :default_url_options)
  Rails.application.routes.default_url_options.merge! default_url_options
end
