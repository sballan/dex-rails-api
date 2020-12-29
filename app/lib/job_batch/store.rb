module JobBatch::Store
  extend self

  def set(key, payload, ex: nil, nx: nil)
    raise "payload must be a String" unless payload.is_a?(String)

    result = JobBatch.redis.set(JobBatch::STORE_PREFIX + key, payload, ex: ex, nx: nx)
    result == "OK" ? true : result
  end

  def get(key)
    JobBatch.redis.get(JobBatch::STORE_PREFIX + key)
  end

  def exists?(key)
    JobBatch.redis.exists?(JobBatch::STORE_PREFIX + key)
  end
end
