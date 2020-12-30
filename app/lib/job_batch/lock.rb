module JobBatch::Lock
  extend self

  def with_lock(name, ttl=nil, &block)
    raise "Block required" unless block

    key = lock(name, ttl)
    raise "Failed to acquire lock" unless key

    block.call

    success = unlock(name, key)
    raise "Failed to unlock"
  end

  def lock(name, ttl=nil, retry_ttl=5.seconds, retry_length=0.1.seconds)
    key = SecureRandom.uuid
    success = write_lock(name, key, ex: ttl)

    if success
      key
    elsif retry_length < retry_ttl
      sleep retry_length
      lock(name, ttl, retry_ttl - retry_length, retry_length * 2)
    else
      raise "Failed to acquire lock"
    end
  end

  def unlock(name, key)
    return false unless correct_key?(name, key)

    success = delete_lock(name)
    success == 1
  end

  def correct_key?(name, possible_key)
    return false if name.nil? || possible_key.nil?

    actual_key = fetch_lock_key(name)
    possible_key == actual_key
  end

  protected

  def write_lock(name, key, ex:nil)
    ex ||= JobBatch::DEFAULT_LOCK_TTL 
    JobBatch.redis.set(JobBatch::LOCK_PREFIX + name, key, ex: ex, nx: true)
  end

  def fetch_lock_key(name)
    JobBatch.redis.get(JobBatch::LOCK_PREFIX + name)
  end

  def delete_lock(name)
    JobBatch.redis.del(JobBatch::LOCK_PREFIX + name)
  end
end
