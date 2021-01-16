module ActiveLock::Config
  extend self

  PREFIX = "ActiveLock/"

  DEFAULT_LOCK_TTL = 1.hour
  DEFAULT_LOCK_RETRY_TIME = 15.seconds
  DEFAULT_LOCK_RETRY_LENGTH = 0.01.seconds

  def lock_default_opts
    {
      ttl: DEFAULT_LOCK_TTL,
      retry_time: DEFAULT_LOCK_RETRY_TIME,
      retry_length: DEFAULT_LOCK_RETRY_LENGTH
    }
  end

  def redis
    Redis.current
  end
end
