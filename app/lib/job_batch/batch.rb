class JobBatch::Batch
  PREFIX = "Batch/"

  def initialize(batch_id)
    @batch_id = batch_id
    raise "Job not in redis" unless self.class.exists?(batch_id)
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
    JobBatch::Lock.with_lock(@batch_id) do
      result = block.call(self.class.fetch_batch_data(@batch_id))
      JobBatch::Store.set(PREFIX + @batch_id, result.to_json)
    end
  end

  def open(&block)
    raise "This should not be possible: batch was already open" if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = @batch_id
    block.call(@batch_id)
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = nil
  end


  def self.create(callback_class, args_array, ex: JobBatch::DEFAULT_BATCH_TTL)
    batch_id = SecureRandom.uuid
    batch_data = {
      created_at: DateTime.now.utc.to_s,
      jobs: []
    }.to_json

    lock_key = JobBatch::Lock.lock(batch_id)

    raise "Failed to create batch: could not lock batch" unless lock_key

    result = JobBatch::Store.set(PREFIX + batch_id, batch_data, ex: ex, nx: true)
    batch = fetch(batch_id)
    unlock_result = JobBatch::Lock.unlock(batch_id, lock_key)

    raise "Failed to create batch: could not write batch" unless result
    raise "Failed to create batch: could not read batch" unless batch
    raise "Failed to create batch: could not unlock batch" unless unlock_result

    batch
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
