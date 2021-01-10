# Sidekiq need size of concurrency + 2
# https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb#L51
#
# NOTE: I was never able to get this to work with a manually created ConnctionPool.  It would freeze up sometimes
# while queueing jobs with perform_later.  I never figured out why.

default_redis_url = ENV['REDIS_URL'] || nil
default_redis_connection = Redis.new(url: default_redis_url)
default_redis_pool_concurrency = ENV.fetch('RAILS_MAX_THREADS', 5).to_i + 5
DEFAULT_REDIS = ConnectionPool::Wrapper.new(size: default_redis_pool_concurrency, timeout: 3) { default_redis_connection}

sidekiq_redis_url = ENV['SIDEKIQ_REDIS_URL'] || default_redis_url
Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_redis_url }
end