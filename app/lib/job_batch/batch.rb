class JobBatch::Batch < RedisModel
  REDIS_PREFIX = "JobBatch/Batches/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { {id: id, active: true,} }

  belongs_to :parent, 'JobBatch::Batch', inverse_of: :children
  has_many :children, 'JobBatch::Batch', inverse_of: :parent
  has_many :jobs, 'JobBatch::Job', inverse_of: :batches

  def finished!
    callback_klass_name = self[:callback_klass]
    callback_klass = Object.const_get(callback_klass_name) unless callback_klass_name.blank?

    callback_args = JSON.parse(self[:callback_args]) unless self[:callback_args].blank?
    callback_args ||= []

    if callback_klass.respond_to? :perform_later
      Rails.logger.info "Finished Batch #{id}, about to queue callback #{callback_klass_name}"
      callback_klass.perform_later *callback_args
    else
      raise "Batch #{id} tried to use an invalid callback"
    end

    self[:active] = false
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
      JobBatch::Job.create(job.id, batch_id: id)
    end
  end

  def open(&block)
    raise "This should not be possible: batch was already open" if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = id
    block.call(id)
  ensure
    Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = nil
  end

  def self.create(id=nil, attrs={})
    attrs[:callback_klass] = attrs[:callback_klass].to_s
    attrs[:callback_args] = attrs[:callback_args].to_json if attrs[:callback_args].is_a? Array
    raise "Invalid callback args" unless attrs[:callback_args].is_a?(String) || attrs[:callback_args].nil?

    attrs[:created_at] ||= DateTime.now.utc.to_s
    id ||= SecureRandom.uuid

    super(id, attrs)
  end

end
