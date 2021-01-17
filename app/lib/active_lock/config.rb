module ActiveLock::Config
  extend self

  DEFAULT_LOCK_TTL = 6.hours
  DEFAULT_LOCK_RETRY_TIME = 15.seconds
  DEFAULT_LOCK_RETRY_LENGTH = 0.1.seconds

  PREFIX = "ActiveLock/"

  def redis
    Redis.current
  end
end
