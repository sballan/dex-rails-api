module JobBatch::Lock
  extend self

  DEFAULT_TTL = 1.minute

  def with_lock(name, ttl=DEFAULT_TTL, &block)
    raise "Block required" unless block

    key = lock(name, ttl)
    raise "Failed to acquire lock" unless key

    block.call

    success = unlock(name, key)
    raise "Failed to unlock"
  end

  def lock(name, ttl=DEFAULT_TTL)
    key = SecureRandom.uuid
    success = JobBatch.redis.set(name, key, ex: 5.minutes, nx: true)
    success ? key : nil
  end

  def unlock(name, key)
    correct_key = JobBatch.redis.get(name) == key
    if correct_key
      success = JobBatch.redis.del(name)
      return success == 1
    end

    false
  end
end