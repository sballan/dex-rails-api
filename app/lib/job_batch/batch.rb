class JobBatch::Batch
  PREFIX = "Batch/"

  attr_reader :id

  def initialize(batch_id)
    @id = batch_id
  end

  def with_lock(&block)
    self.class.with_lock(id, &block)
  end

  def add_job(job_id)
    with_lock do
      if JobBatch::Job.exists?(job_id)
        job = JobBatch::Job.find(job_id)
        raise "Couldn't find an existing job" if job.nil?

        job.with_lock do
          if job.batch.id == id
            Rails.logger.warn "Trying to add a job to a batch that already belongs to this batch"
          else
            raise "Trying to add a job to this batch that is already in a different batch"
          end
        end
      else
        JobBatch::Job.create(job_id, id)
      end
    end
  end

  def open(&block)
    raise "This should not be possible: batch was already open" if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = id
    block.call(id)
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = nil
  end

  # This awesome method locks the batch, and then gives us every job_id that matches the batch - with a lock
  # on the job too.
  def jobs
    Enumerator.new do |y|
      with_lock do
        # Iterate over all jobs
        JobBatch.redis.scan_each(match: JobBatch::JOBS_PREFIX + "*") do |job_id|
          job = JobBatch::Job.new(job_id)
          # For each job, check if it has the right batch id - yield to block if it does.
          job.with_data do |data|
            break unless data[:batch_id] == id
            y << data
          end
        end
      end
    end
  end

  def with_jobs()

  end

  def self.with_lock(batch_id, &block)
    lock_key = JobBatch::Lock.lock(batch_id)
    raise "could not lock Batch #{batch_id}" unless lock_key

    block.call

    unlock_result = JobBatch::Lock.unlock(batch_id, lock_key)
    raise "could not unlock Batch #{batch_id}" unless unlock_result
  end

  def self.fetch_batch_data(batch_id)
    result = JobBatch::Store.get(PREFIX + batch_id)
    raise unless result.present?

    JSON.parse(result, symbolize_keys: true)
  end

  def self.exists?(batch_id)
    JobBatch::Store.exists?(PREFIX + batch_id)
  end
end
