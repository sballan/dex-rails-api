module ActiveLock::Lock
  extend self

  def with_lock(name, opts={}, &block)
    opts = ActiveLock::Config.lock_default_opts.merge(opts)
    raise ArgumentError.new("Block required") unless block.present?

    key = lock(name, opts)

    block.call(key)

    unlock(name, key)
  end

  def lock(name, opts={})
    opts = ActiveLock::Config.lock_default_opts.merge(opts)
    ttl, retry_time, retry_length = opts.values_at(:ttl, :retry_time, :retry_length)

    key = SecureRandom.uuid
    success = write_lock(name, key, ex: ttl)

    if success
      key
    elsif retry_time > 0.seconds
      sleep retry_length

      lock(
        name,
        ttl: ttl,
        retry_time: retry_time - retry_length,
        retry_length: retry_length * 2 * rand(0.5..1.5)
      )
    else
      raise ActiveLock::Errors::FailedToLockError.new("Failed to acquire lock")
    end
  end

  def unlock(name, key)
    unless correct_key?(name, key)

    end

    delete_lock(name)
  end

  def correct_key?(name, possible_key)
    return false unless name.present? && possible_key.present?

    actual_key = fetch_lock_key(name)
    possible_key == actual_key
  end

  protected

  def write_lock(name, key, ex: nil)
    ex ||= ActiveLock::Config::DEFAULT_LOCK_TTL
    raise ArgumentError.new("Cannot write_lock with blank name") if name.blank?

    res = ActiveLock::Config.redis.set(ActiveLock::Config::PREFIX + name, key, ex: ex, nx: true)
    raise ActiveLock::Errors::FailedToLockError.new "Failed to write lock" unless res == true
  end

  def fetch_lock_key(name)
    res = ActiveLock::Config.redis.get(ActiveLock::Config::PREFIX + name)
    raise ActiveLock::Errors::Base.new "Failed fetch lock" unless res.present?

    res
  end

  def delete_lock(name)
    res = ActiveLock::Config.redis.del(ActiveLock::Config::PREFIX + name)
    raise ActiveLock::Errors::FailedToUnlockError.new "Failed to delete lock" unless res == 1

    res
  end
end
