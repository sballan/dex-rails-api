class JobBatch::Job < RedisModel
  REDIS_PREFIX = "JobBatch/Jobs/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { { id: id, active: true } }


  attr_reader :id

  def initialize(job_id)
    # If the job_id starts with our Redis prefix, we can safely remove it
    job_id = job_id.remove(/^#{REDIS_PREFIX}/)
    super(job_id)
  end

  # @return [JobBatch::Batch]
  def batch
    batch_id = self[:batch_id]

    unless batch_id.present?
      raise "Couldn't get batch for Job(#{id})"
    end

    JobBatch::Batch.new(batch_id)
  end

  def destroy!
    batch.with_lock do
      JobBatch.redis.del(key)
    end
  end

  def ==(other_job)
    id == other_job.id && batch.id == other_job.batch.id
  end

  def self.create(job_id, attrs={})
    attrs[:batch_id] ||= SecureRandom.uuid
    batch = JobBatch::Batch.new(attrs[:batch_id])
    job = nil

    with_lock(job_id) do
      batch.with_lock do
        job = super(job_id, attrs)
      end
    end

    job
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

  def self.all(&block)
    Enumerator.new do |y|
      JobBatch.redis.scan_each(match: JobBatch::JOBS_PREFIX + "*") do |job_id|
        y << new(job_id)
      end
    end
  end

  def self.fetch_data(job_id)
    JobBatch.redis.mapped_hmget(key_for(job_id), *REDIS_HASH_KEYS).with_indifferent_access
  end

  def self.exists?(job_id)
    JobBatch.redis.exists?(key_for(job_id))
  end
end
