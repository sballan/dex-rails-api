module ActiveLock::Lockable
  extend ActiveSupport::Concern

  def lock_id
    send(self.class.lock_id_name)
  end

  def lock(opts = {})
    ActiveLock::Lock.lock(lock_id, opts)
  end

  def unlock(key)
    ActiveLock::Lock.unlock(lock_id, key)
  end

  def with_lock(existing_key = nil, opts = {}, &)
    ActiveLock::Lock.with_lock(lock_id, existing_key, opts, &)
  end

  class_methods do
    def lock_id_name
      @lock_id_name || :id
    end

    def set_lock_id_name(lock_id_name)
      raise "Lock name must be symbol" unless lock_id_name.is_a? Symbol

      @lock_id_name = lock_id_name
    end
  end
end
