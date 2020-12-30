class JobBatch::Job
  REDIS_HASH_KEYS=%w[batch_id created_at]

  attr_reader :id

  def initialize(job_id)
    # If the job_id starts with our Redis prefix, we can safely remove it
    @id = job_id.remove(/^#{JobBatch::JOBS_PREFIX}/)
  end

  def key
    self.class.key_for(id)
  end

  # @return [JobBatch::Batch]
  def batch
    batch_id = nil
    with_lock do
      result = JobBatch.redis.hmget(key, 'batch_id')
      batch_id = result.first
    end

    unless batch_id.present?
      raise "Couldn't get batch for Job(#{id})"
    end

    JobBatch::Batch.new(batch_id)
  end

  def with_data(&block)
    with_lock do
      data = JobBatch.redis.mapped_hmget(key, *REDIS_HASH_KEYS).with_indifferent_access
      block.call(data)
    end
  end

  def with_lock(&block)
    self.class.with_lock(id, &block)
  end

  def destroy!
    with_lock do
      batch.with_lock do
        JobBatch.redis.del(key)
      end
    end
  end

  def self.create(job_id, batch_id=nil)
    batch_id ||= SecureRandom.uuid
    batch = JobBatch::Batch.new(batch_id)

    with_lock(job_id) do
      batch.with_lock do
        JobBatch.redis.mapped_hmset(
          key_for(job_id),
          batch_id: batch_id,
          active: true,
          created_at: DateTime.now.utc.to_s
        )
      end
    end
    raise "Job not in redis" unless exists?(job_id)

    self.new(job_id)
  end

  def self.with_lock(job_id, &block)
    lock_key = ActiveLock::Lock.lock(job_id)
    raise "could not lock Job #{job_id}" unless lock_key

    block.call

    unlock_result = ActiveLock::Lock.unlock(job_id, lock_key)
    raise "could not unlock Job #{job_id}" unless unlock_result
  end

  def self.find(job_id)
    return nil unless exists?(job_id)

    new(job_id)
  end

  def self.key_for(job_id)
    JobBatch::JOBS_PREFIX + job_id
  end

  def self.exists?(job_id)
    JobBatch.redis.exists?(key_for(job_id))
  end
end
