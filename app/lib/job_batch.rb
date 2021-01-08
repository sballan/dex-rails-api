module JobBatch
  extend self

  DEFAULT_LOCK_TTL = 1.minute
  DEFAULT_LOCK_RETRY_TIME = 15.seconds
  DEFAULT_BATCH_TTL = 6.hours

  PREFIX = "JobBatch/"
  LOCK_PREFIX = PREFIX + "Lock/"
  JOBS_PREFIX = PREFIX + "Jobs/"
  BATCHES_PREFIX = PREFIX + "Batches/"

  THREAD_OPEN_BATCH_SYMBOL = :open_job_batch_id

  # @return [Redis]
  def redis
    # This might be really stupid, but I think it actually will work
    DEFAULT_REDIS
  end
end
