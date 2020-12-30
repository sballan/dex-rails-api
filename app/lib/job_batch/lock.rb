module JobBatch::Lock
  extend self

  def with_lock(name, ttl=JobBatch::DEFAULT_LOCK_TTL, &block)
    raise "Block required" unless block

    key = lock(name, ttl)
    raise "Failed to acquire lock" unless key

    block.call

    success = unlock(name, key)
    raise "Failed to unlock"
  end

  def lock(name, ttl=JobBatch::DEFAULT_LOCK_TTL)
    key = SecureRandom.uuid
    success = JobBatch.redis.set(JobBatch::LOCK_PREFIX + name, key, ex: ttl, nx: true)
    success ? key : nil
  end

  def unlock(name, key)
    correct_key = JobBatch.redis.get(JobBatch::LOCK_PREFIX + name) == key
    if correct_key
      success = JobBatch.redis.del(JobBatch::LOCK_PREFIX + name)
      return success == 1
    end

    false
  end
end
