require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SdcApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    paths = [
      Rails.root.join("app/services"),
    ]

    config.autoload_paths += paths
    config.eager_load_paths += paths

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # if we need additional middlewares, checkout http://guides.rubyonrails.org/api_app.html#other-middleware

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.default_locale = :'pt-BR'
    config.i18n.available_locales = %w[pt-BR en-US es-PY fr-FR]
    config.time_zone = 'Brasilia'

    # criamos o arquivo sol.yml (em config/) e com isso fazemos o load do mesmo nas `ENV`
    # explicitamos os nomes (nesse caso) para PDF_CONTRACT_NAME_STATE, PDF_CONTRACT_XXX
    config_file = Rails.root.join('config', 'sol.yml')
    if File.exists?(config_file)
      config = YAML.load(File.read(config_file))
      config.fetch(Rails.env, {}).each do |key, value|
        if value.kind_of? Hash
          value.each { |k, v| ENV["#{key.upcase}_#{k}"] = v }
        else
          ENV[key] = value
        end
      end
    end

    # Easy generation of structure.sql if needed
    # config.active_record.schema_format = :sql
  end
end
