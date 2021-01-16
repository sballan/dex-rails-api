module ActiveLock::Config
  extend self

  PREFIX = "ActiveLock/"

  DEFAULT_LOCK_TTL = 1.hour
  DEFAULT_LOCK_RETRY_TIME = 15.seconds
  DEFAULT_LOCK_RETRY_WAIT = 0.01.seconds

  def lock_default_opts
    {
      ttl: DEFAULT_LOCK_TTL,
      retry_time: DEFAULT_LOCK_RETRY_TIME,
      retry_wait: DEFAULT_LOCK_RETRY_WAIT
    }
  end

  def redis_connection
    Redis.current
  end

  def with_redis(&block)
    raise ArgumentError, "with_redis requires block" unless block.present?

    block.call(redis_connection)
  end
end
