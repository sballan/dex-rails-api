class RedisModel
  REDIS_PREFIX = "Abstract"
  REDIS_HASH_KEYS = %w[id]
  REDIS_DEFAULT_DATA = ->(id) { {id: id} }

  attr_reader :id
  def initialize(id)
    @id = id.remove(/^#{self.class::REDIS_PREFIX}/)
  end

  def key
    self.class.key_for(id)
  end

  def with_lock(&block)
    self.class.with_lock(id, &block)
  end

  def with_data(&block)
    with_lock do
      data = self.class.fetch_data(id)
      block.call(data)
    end
  end

  def [](field_name)
    value = self.class.redis.hmget(key, field_name)
    value.first
  end

  def []=(field_name, field_value)
    self.class.redis.hmset(key, field_name, field_value)
  end

  def self.all(&block)
    Enumerator.new do |y|
      redis.scan_each(match: self::REDIS_PREFIX + "*") do |id|
        y << new(id)
      end
    end
  end

  def self.find(id)
    return nil unless exists?(id)

    new(id)
  end

  def self.create(id=nil, attrs={})
    raise "Invalid attrs" unless attrs.is_a?(Hash)

    id ||= SecureRandom.uuid
    attrs = self::REDIS_DEFAULT_DATA.call(id).merge(attrs)

    redis.mapped_hmset(key_for(id), attrs)
    new(id)
  end

  def self.find_or_create(id)
    with_lock(id) do
      model = find(id)
      return model unless model.nil?

      attrs = self::REDIS_DEFAULT_DATA.call(id)
      return create(id, attrs)
    end
  end


  def self.with_lock(id, &block)
    lock_key = ActiveLock::Lock.lock(id)
    raise "could not lock #{self.name} #{id}" unless lock_key

    block.call(lock_key)
  ensure
    # If something goes wrong, we want to unlock. If this behavior is not desired, manage the lock manually
    unlock_result = ActiveLock::Lock.unlock(id, lock_key)
    raise "could not unlock #{self.name} #{id}" unless unlock_result
  end

  def self.fetch_data(id)
    data = redis.mapped_hmget(key_for(id), *self::REDIS_HASH_KEYS).with_indifferent_access
    raise unless data.present?

    data
  end

  def self.key_for(id)
    self::REDIS_PREFIX + id
  end

  def self.exists?(id)
    redis.exists?(self::REDIS_PREFIX + id)
  end

  def self.redis
    Redis.current
  end
end
