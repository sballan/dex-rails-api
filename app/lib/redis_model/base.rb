class RedisModel::Base
  set_key_prefix :base
  set_key_suffix :record
  set_field_names %i[id]

  include ActiveLock::Lockable
  set_lock_id_name :id

  attr_reader :id

  def initialize(id)
    @id = id.remove(/^#{self.class.key_prefix}\//).remove(/\/#{self.class.key_prefix}$/)
  end

  def key
    self.class.key_for(id)
  end

  def ==(other_object)
    return (key == other_object.key) if other_object.respond_to? :key

    false
  end

  def fetch_data
    self.class.fetch_data(id)
  end

  def [](field_name)
    value = self.class.redis.hmget(key, field_name)
    value.first
  end

  def []=(field_name, field_value)
    self.class.redis.hmset(key, field_name, field_value)
  end

  def self.each(&block)
    Enumerator.new do |y|
      redis.scan_each(match: key_prefix + "/*/" + key_suffix) do |id|
        y << new(id)
      end
    end
  end

  def self.all
    redis.scan_each(match: key_prefix + "/*/" + key_suffix).map do |id|
      new(id)
    end
  end

  def self.find(id)
    return nil unless exists?(id)

    new(id)
  end

  def self.create(id=nil, attrs={})
    id ||= SecureRandom.uuid
    raise RedisModel::Errors::IdNotUniqueError.new("Cannot create #{name}: it already exists") if exists? id

    raise ArgumentError.new("Invalid attrs") unless attrs.is_a?(Hash)
    attrs = {id: id}.merge(attrs)

    with_redis do |r|
      r.mapped_hmset(key_for(id), attrs)
    end

    new(id)
  end

  def self.find_or_create(id, attrs)
    with_lock(id) do
      model = find(id)
      return model unless model.blank?

      return create(id, attrs)
    end
  end

  def self.fetch_data(id)
    with_redis do |r|
      data = r.mapped_hmget(key_for(id), *field_names).with_indifferent_access
      raise RedisModel::Errors::RecordMissingError.new("Missing #{name}(#{id})") unless data.present?

      data
    end
  end

  def self.key_for(id)
    key_prefix + "/#{id}/" + key_suffix
  end

  def self.exists?(id)
    with_redis {|r| r.exists?(key_for(id)) }
  end

  # @yield [r] Redis connection
  # @yieldparam [Redis] a Redis connection
  def self.with_redis(&block)
    raise ArgumentError.new('need block') unless block_given?

    yield(DEFAULT_REDIS)
  end

  class << self
    attr_reader :key_prefix, :field_names, :key_suffix

    def set_key_prefix(key_prefix)
      unless key_prefix.is_a? Symbol
        raise RedisModel::Errors::ModelConfigurationError.new("key_prefix must be symbol")
      end

      @key_prefix = key_prefix
    end

    def set_key_suffix(key_suffix)
      unless key_suffix.is_a? Symbol
        raise RedisModel::Errors::ModelConfigurationError.new("key_suffix must be symbol")
      end

      @key_suffix = key_suffix
    end

    def set_field_names(field_names)
      unless field_names.is_a? Array
        raise RedisModel::Errors::ModelConfigurationError.new("field_names must be an Array")
      end

      unless field_names.all? {|fn| fn.is_a? Symbol }
        raise RedisModel::Errors::ModelConfigurationError.new("field_names must be Symbols")
      end

      @field_names = field_names
    end
  end
end
