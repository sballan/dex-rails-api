class JobBatch::Batch
  PREFIX = "Batch/"

  attr_reader :id

  def initialize(batch_id)
    @id = batch_id
  end

  def with_lock(&block)
    self.class.with_lock(id, &block)
  end

  # TODO: There may be an edge case here...What happens if we create the job somewhere else in between
  # checking that it exists and trying to create it here?
  def add_job(job)
    if JobBatch::Job.exists?(job.id)
      job.with_lock do
        if job.batch.id == id
          Rails.logger.warn "Trying to add a job to a batch that already belongs to this batch"
        else
          # NOTE: This case might actually make sense...maybe we should allow putting a job in a different batch...
          raise "Trying to add a job to this batch that is already in a different batch"
        end
      end
    else
      JobBatch::Job.create(job.id, id)
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
            # TODO: think about this carefully.  Is this safe?
            y << job
          end
        end
      end
    end
  end

  def self.create!(batch_id, callback_klass=nil, callback_args=nil)
    callback_klass = callback_klass.to_s
    callback_args = callback_args.to_json if callback_args.is_a? Array
    raise "Invalid callback args" unless callback_args.is_a? String

    JobBatch.redis.mapped_hmset(
      key_for(batch_id),
      active: true,
      callback_klass: callback_klass,
      callback_args: callback_args,
      created_at: DateTime.now.utc.to_s
    )
  end

  def self.key_for(batch_id)
    JobBatch::BATCHES_PREFIX + batch_id
  end

  def self.with_lock(batch_id, &block)
    lock_key = ActiveLock::Lock.lock(batch_id)
    raise "could not lock Batch #{batch_id}" unless lock_key

    block.call(lock_key)

    unlock_result = ActiveLock::Lock.unlock(batch_id, lock_key)
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
