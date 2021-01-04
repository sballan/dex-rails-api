class JobBatch::Batch < RedisModel
  REDIS_PREFIX = "JobBatch/Batches/"
  REDIS_HASH_KEYS = %w[active callback_klass callback_args created_at]
  REDIS_DEFAULT_DATA = ->(id) { {id: id, active: true,} }

  belongs_to :parent, 'JobBatch::Batch', inverse_of: :children
  has_many :children, 'JobBatch::Batch', inverse_of: :parent
  has_many :jobs, 'JobBatch::Job', inverse_of: :batches

  def destroy!
    # parent is a relation, so we need to grab it before using multi
    p = parent
    self.class.redis.multi do
      self.class.redis.del(key)
      p.present? && p.children_delete(id)
    end
  end

  def finished!
    callback_klass_name = self[:callback_klass]
    callback_klass = Object.const_get(callback_klass_name) unless callback_klass_name.blank?

    callback_args = JSON.parse(self[:callback_args]) unless self[:callback_args].blank?
    callback_args ||= []

    if callback_klass.respond_to?(:perform_later)
      Rails.logger.info "Finished Batch #{id}, about to queue callback #{callback_klass_name}"
      callback_klass.perform_later *callback_args
    elsif callback_klass.present?
      raise "Batch #{id} tried to use an invalid callback"
    end

    p = parent
    destroy!

    if p.present? && p.jobs.empty? && p.children.empty?
      p.finished!
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

  def self.opened_batch
    if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL].present?
      new(Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL])
    else
      nil
    end
  end

end
