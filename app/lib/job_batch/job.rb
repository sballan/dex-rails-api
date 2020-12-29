class JobBatch::Job
  PREFIX = "Jobs/"

  def initialize(job_id)
    @job_id = job_id
    raise "Job not in redis" unless self.class.exists?(job_id)
  end



  def self.create(job_id, batch_id)
    lock_key = JobBatch::Lock.lock(job_id)

    raise "Failed to add JobBatch::Job to redis: could not lock Job" unless lock_key

  end

end
