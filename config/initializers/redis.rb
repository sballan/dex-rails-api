# Sidekiq need size of concurrency + 2
# https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb#L51

sidekiq_concurrency = ENV.fetch('RAILS_MAX_THREADS', 5).to_i + 2

if ENV['REDIS_URL'].present?
  default_redis_connection = Redis.new(url: ENV['REDIS_URL'])
else
  # By default, we us Redis gems default connection.  Useful in development.
  default_redis_connection = Redis.current
end

if ENV['SIDEKIQ_REDIS_URL'].present?
  sidekiq_redis_connection = Redis.new(url: ENV['SIDEKIQ_REDIS_URL'])
else
  sidekiq_redis_connection = default_redis_connection
end

DEFAULT_REDIS = default_redis_connection
SIDEKIQ_REDIS = sidekiq_redis_connection

DEFAULT_REDIS_POOL = ConnectionPool.new(size: 1) { DEFAULT_REDIS }
SIDEKIQ_REDIS_POOL = ConnectionPool.new(size: sidekiq_concurrency) { SIDEKIQ_REDIS }

Sidekiq.configure_server do |config|
  config.redis = SIDEKIQ_REDIS_POOL
end

Sidekiq.configure_client do |config|
  config.redis = SIDEKIQ_REDIS_POOL
end