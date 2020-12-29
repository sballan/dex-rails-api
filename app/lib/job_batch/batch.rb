class JobBatch::Batch
  PREFIX = "Batch/"

  attr_reader :id

  def initialize(batch_id)
    @id = batch_id
    raise "Job not in redis" unless self.class.exists?(batch_id)
  end

  def with_lock(&block)
    self.class.with_lock(id, &block)
  end

  def add_job(job_id)
    update do |data|
      jobs_set = Set.new(data[:jobs])
      jobs_set << job_id
      data[:jobs] = jobs_set.to_a
      data
    end
  end

  def update(&block)
    JobBatch::Lock.with_lock(id) do
      result = block.call(self.class.fetch_batch_data(id))
      JobBatch::Store.set(PREFIX + id, result.to_json)
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
  def each_job(&block)
    with_lock do
      # Iterate over all jobs
      JobBatch.redis.scan_each(match: JobBatch::JOBS_PREFIX + "?") do |job_id|
        job = JobBatch::Job.new(job_id)
        # For each job, check if it has the right batch id - yield to block if it does.
        job.with_data do |data|
          break unless data[:batch_id] == id
          block.call(data)
        end
      end
    end
  end

  def self.create(callback_class=nil, args_array=[], ex: JobBatch::DEFAULT_BATCH_TTL)
    batch_id = SecureRandom.uuid
    batch_data = {
      created_at: DateTime.now.utc.to_s,
      jobs: []
    }.to_json

    lock_key = JobBatch::Lock.lock(batch_id)

    raise "Failed to create batch: could not lock batch" unless lock_key

    result = JobBatch::Store.set(PREFIX + batch_id, batch_data, ex: ex, nx: true)
    batch = self.new(batch_id)
    unlock_result = JobBatch::Lock.unlock(batch_id, lock_key)

    raise "Failed to create batch: could not write batch" unless result
    raise "Failed to create batch: could not read batch" unless batch
    raise "Failed to create batch: could not unlock batch" unless unlock_result

    batch
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
