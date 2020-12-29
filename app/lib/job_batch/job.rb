class JobBatch::Job
  def initialize(job_id)
    @job_id = job_id
  end

  def key
    self.class.key_for(@job_id)
  end

  def fetch_data
  end

  def batch

  end

  def with_data(&block)
    with_lock do
      data = JobBatch.redis.mapped_hmget(key, *%w[batch_id created_at]).with_indifferent_access
      block.call(data)
    end
  end

  def with_lock(&block)
    self.class.with_lock(@job_id, &block)
  end

  def self.create(job_id, batch_id=nil)
    batch_id ||= SecureRandom.uuid

    with_lock(job_id) do
      JobBatch::Batch.with_lock(batch_id) do
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
    lock_key = JobBatch::Lock.lock(job_id)
    raise "could not lock Job #{job_id}" unless lock_key

    block.call

    unlock_result = JobBatch::Lock.unlock(job_id, lock_key)
    raise "could not unlock Job #{job_id}" unless unlock_result
  end

  def self.find(job_id)
    return nil unless exists?(job_id)

    new(job_id)
  end

  def self.for_batch_id(batch_id)
    jobs = []
    batch = JobBatch::Batch.new(batch_id)
    batch.each_job do |job|
      jobs << job
    end

    jobs
  end

  def self.key_for(job_id)
    JobBatch::JOBS_PREFIX + job_id
  end

  def self.exists?(job_id)
    JobBatch.redis.exists?(key_for(job_id))
  end

  def self.all_job_ids
  end
end
