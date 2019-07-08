YAML::load_file(Rails.root.join('config', 'sidekiq.yml')).tap do |yaml|
  sidekiq_yaml = {}
  fetch_config = ->(rails_env, *keys) { yaml.dig(rails_env, *keys) || yaml.dig(*keys) }

  # 'env' key overrides default key  (i.e. [:production][:redis_url] > [:redis_url])
  Rails.env.to_sym.tap do |rails_env|
    sidekiq_yaml[:redis] = {
      url:       fetch_config.call(rails_env, :redis, :url),
      namespace: fetch_config.call(rails_env, :redis, :namespace)
    }
  end

  Sidekiq.configure_server do |config|
    config.redis = sidekiq_yaml[:redis]
  end

  Sidekiq.configure_client do |config|
    config.redis = sidekiq_yaml[:redis]
  end

  Sidekiq::Extensions.enable_delay!
end
