class JobBatch::Job < RedisModel
  REDIS_PREFIX = "JobBatch/Jobs/"
  REDIS_HASH_KEYS = %w[id active created_at]
  REDIS_DEFAULT_DATA = ->(id) { { id: id, active: true } }

  belongs_to :batch, 'JobBatch::Batch', inverse_of: :jobs, required: true

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

    attrs[:batch_id] ||= JobBatch::Batch.create.id
    super(job_id, attrs)
  end

  def self.redis
    JobBatch.redis
  end

end
