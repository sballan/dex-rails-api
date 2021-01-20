class JobBatch::Job < RedisModelOld
  REDIS_PREFIX = "JobBatch/Jobs/"
  REDIS_HASH_KEYS = %w[id batch_id active created_at]
  REDIS_DEFAULT_DATA = ->(id) { { id: id, active: true } }

  belongs_to :batch, 'JobBatch::Batch', inverse_of: :jobs, required: true

  def destroy!(lock_key=nil)
    Rails.logger.info "Destroying Job #{id}"

    with_lock(lock_key) do
      # batch is a relation, so we need to grab it before using multi
      b = batch
      self.class.redis.multi do
        self.class.redis.del(key)
        b.jobs_delete(id)
      end
    end
  end

  def ==(other_job)
    id == other_job.id && batch.id == other_job.batch.id
  end

  def self.create(id, attrs={})
    raise "id required to create #{self.name}" if id.blank?

    super(id, attrs)
  end

  def self.redis
    JobBatch.redis
  end

end
