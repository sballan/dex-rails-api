module ActiveLock::Config
  extend self

  DEFAULT_LOCK_TTL = 1.minute
  DEFAULT_LOCK_RETRY_TIME = 15.seconds

  PREFIX = "ActiveLock/"

  def redis
    Redis.current
  end
end
