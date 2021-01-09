class RedisModel
  REDIS_PREFIX = "Abstract"
  REDIS_HASH_KEYS = %w[id]
  REDIS_DEFAULT_DATA = ->(id) { {id: id} }

  attr_reader :id

  def initialize(id)
    # This will match an ActiveJob id
    # TODO: does ActiveJob have a matcher for this?
    @id = id.remove(/^#{self.class::REDIS_PREFIX}/).remove(/\/record$/)
  end

  def key
    self.class.key_for(id)
  end

  def relation_key(relation)
    self.class.relation_key_for(id, relation)
  end

  def ==(other_object)
    if other_object.respond_to? :key
      key == other_object.key
    else
      false
    end
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
      redis.scan_each(match: self::REDIS_PREFIX + "*" + "/record") do |id|
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

    raise "Cannot create #{self.name}: it already exists" if self.exists? id

    attrs = self::REDIS_DEFAULT_DATA.call(id).merge(attrs)

    redis.multi do
      redis.mapped_hmset(key_for(id), attrs)

      # Make sure all belongs_to fields are set
      belongs_to_klasses.each do |key, value|
        next unless value[:required] == true

        unless attrs.keys.include?(:"#{key}_id")
          raise "#{self.name} cannot be created without a #{key} relation"
        end
      end

      # Call <relation>_insert for each belongs_to relation
      attrs.each do |key, value|
        relation_name = key.to_s.remove(/_id$/).to_sym
        next unless belongs_to_klasses.has_key?(relation_name)

        relation = belongs_to_klasses[relation_name][:class].find(value)
        relation.send(:"#{belongs_to_klasses[relation_name][:inverse_of]}_insert", id)
      end
    end
    new(id)
  end

  def self.find_or_create(id, attrs)
    with_lock(id) do
      model = find(id)
      return model unless model.nil?

      return create(id, self::REDIS_DEFAULT_DATA.call(id).merge(attrs))
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
    self::REDIS_PREFIX + id + "/record"
  end

  def self.relation_key_for(id, relation)
    self::REDIS_PREFIX + id + "/#{relation}_relation"
  end

  def self.exists?(id)
    redis.exists?(key_for(id))
  end

  def self.redis
    DEFAULT_REDIS
  end

  protected

  def self.belongs_to_klasses
    @belongs_to_klasses ||= {}
  end

  def self.has_many_klasses
    @has_many_klasses ||= {}
  end

  def self.belongs_to(relation_name, klass_name, inverse_of:, required: false)
    klass = Object.const_get(klass_name)
    unless klass.const_defined?(:REDIS_PREFIX)
      raise "#{self.name} cannot belong_to a class with no REDIS_PREFIX"
    end

    belongs_to_klasses[relation_name] = {
        class: klass,
        inverse_of: inverse_of,
        required: required
    }

    define_method(relation_name) do
      relation_id = self.send(:[], :"#{relation_name}_id")
      relation = klass.find(relation_id) unless relation_id.blank?
      if relation.blank? && self.class.belongs_to_klasses[relation_name][:required]
        raise "#{self.class.name} #{id} is missing required relation #{relation_name}"
      end
      relation
    end
  end

  def self.has_many(relation_name, klass_name, inverse_of)
    klass = Object.const_get(klass_name)
    unless klass.const_defined?(:REDIS_PREFIX)
      raise "#{self.name} cannot has_many a class with no REDIS_PREFIX"
    end

    has_many_klasses[relation_name] = {
        class: klass,
        inverse_of: inverse_of
    }

    define_method(:"#{relation_name}_insert") do |relation_id|
      self.class.redis.sadd(self.send(:relation_key, relation_name), relation_id)
    end

    define_method(:"#{relation_name}_delete") do |relation_id|
      self.class.redis.srem(self.send(:relation_key, relation_name), relation_id)
    end

    define_method(relation_name) do
      relation_ids = self.class.redis.smembers(self.send(:relation_key, relation_name))
      relation_ids.map { |r_id| klass.new(r_id) }
    end
  end
end
