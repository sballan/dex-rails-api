class JobBatch::Job < RedisModel
  REDIS_PREFIX = "JobBatch/Jobs/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { { id: id, active: true } }

  belongs_to :batch, 'JobBatch::Batch', :jobs

  def destroy!
    # batch is a relation, so we need to grab it before using multi
    b = batch
    self.class.redis.multi do
      self.class.redis.del(key)
      b.jobs_delete(id)
    end
  end

  def ==(other_job)
    id == other_job.id && batch.id == other_job.batch.id
  end

  def self.create(job_id, attrs={})
    raise "job_id required to create #{self.name}" if job_id.blank?

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
