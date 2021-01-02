class JobBatch::Batch < RedisModel
  REDIS_PREFIX = "JobBatch/Batches/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { {id: id, active: true,} }

  attr_reader :id
  def initialize(batch_id)
    batch_id = batch_id.remove(/^#{REDIS_PREFIX}/)
    super(batch_id)
  end

  def finished!
    callback_klass_name = JobBatch.redis.hmget(key, 'callback_klass')
    callback_klass = Object.const_get(callback_klass_name)
    raise "invalid callback_klass" unless callback_klass.is_a?(ApplicationJob)

    # set active to false in redis?
    # perhaps a callback queue??

    callback_klass.perform_later
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
    JobBatch::Job.all.filter do |job|
      job.batch.id == id
    end
  end


  def self.create(id=nil, attrs={})
    callback_klass = attrs[:callback_klass].to_s
    callback_args = attrs[:callback_klass].to_json if attrs[:callback_klass].is_a? Array
    raise "Invalid callback args" unless callback_args.is_a?(String) || callback_args.nil?

    id ||= SecureRandom.uuid

    super(id, {
      callback_klass: callback_klass,
      callback_args: callback_args,
      created_at: DateTime.now.utc.to_s
    })
  end

end
