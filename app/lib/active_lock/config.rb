module ActiveLock::Config
  extend self

  DEFAULT_LOCK_TTL = 1.hour
  DEFAULT_LOCK_RETRY_TIME = 15.seconds
  DEFAULT_LOCK_RETRY_LENGTH = 0.01.seconds

  PREFIX = "ActiveLock/"

  def redis
    Redis.current
  end
end
