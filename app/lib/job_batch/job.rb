class JobBatch::Job < RedisModel
  REDIS_PREFIX = "JobBatch/Jobs/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { { id: id, active: true } }

  belongs_to :batch, 'JobBatch::Batch', :jobs

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
end
