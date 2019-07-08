# see PR https://github.com/rails/rails/pull/31134#issue-152131596 for full options
# ref https://www.engineyard.com/blog/rails-5-2-redis-cache-store

Rails.application.config.before_configuration do
  break if Rails.env.test?

  cache_config = Rails.application.secrets.cache.deep_symbolize_keys

  Rails.application.config.cache_store = :redis_cache_store, cache_config
  Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
end
