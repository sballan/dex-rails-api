module JobBatch
  extend self

  DEFAULT_LOCK_TTL = 1.minute
  DEFAULT_BATCH_TTL = 6.hours

  PREFIX = "JobBatch/"
  LOCK_PREFIX = PREFIX + "Lock/"
  STORE_PREFIX = PREFIX + "Store/"
  JOBS_PREFIX = PREFIX + "Jobs/"
  BATCHES_PREFIX = PREFIX + "Batches/"

  THREAD_OPEN_BATCH_SYMBOL = :open_job_batch_id

  # @return [Redis]
  def redis
    Redis.current
  end
end
