# Restoring the "secrets.yml" configuration behavior (from Rails 4.1 til 5.2).
# Be sure to restart your server when you modify this file.
require 'erb'

# Before Rails Application gets configured, we're extending Rails::Application with the
# "RailsApplicationSecrets" module, re-creating methos `Rails.application.secrets` and
# `Rails.application.secrets=`.
Rails.application.config.before_configuration do
  # this is executed in "Rails" context, with:
  #   app => `Rails.application`
  #   config => `Rails.application.config`

  module RailsApplicationSecrets
    def secrets
      @secrets ||= ActiveSupport::OrderedOptions.new.tap do |secrets|
        yaml = Rails.root.join('config', 'secrets.yml')
        return unless File.exist?(yaml)

        all_secrets = YAML.load(ERB.new(IO.read(yaml)).result) || {}
        shared_secrets = all_secrets.fetch('shared', {}).symbolize_keys
        env_secrets = all_secrets.fetch(::Rails.env, {}).symbolize_keys

        secrets.merge! shared_secrets.deep_merge(env_secrets)
      end
    end

    def secrets=(secrets)
      @secrets = secrets
    end
  end

  Rails.application.extend(RailsApplicationSecrets) # same as `app.extend()`
end

# Before Rails gets initialized, we're "preloading" the secrets from config/secrets.yml.
Rails.application.config.before_initialize do
  # this is executed in "Rails" context, with:
  #   app => `Rails.application`
  #   config => `Rails.application.config`

  Rails.application.secrets # the getter method fetches and memoizes the data
end

# And after initialization, we are running a sanity check on required options
Rails.application.config.after_initialize do
  # this is executed in "Rails" context, with:
  #   app => `Rails.application`
  #   config => `Rails.application.config`

  if Rails.application.secrets.secret_key_base.blank?
    raise "Missing `secret_key_base` for '#{Rails.env}' environment on `config/secrets.yml`"
  else
    Rails.application.config.secret_key_base = Rails.application.secrets.secret_key_base
  end
end
