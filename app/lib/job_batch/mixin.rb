# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  PREFIX = "Job/"

  attr_reader :batch_id

  def self.included(mod)
    mod.before_enqueue do |job|
      if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL].blank?
        Rails.logger.debug "There is no currently open batch, so let's open one for this thread"
        Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL] = SecureRandom.uuid
      end

      batch_id = Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]

      batch = JobBatch::Batch.new(batch_id)
      jb_job = JobBatch::Job.new(job.job_id)
      batch.add_job(jb_job)
      Rails.logger.debug "Successfully added Job #{jb_job.id} to Batch #{batch.id}"
    end

    mod.after_perform do |job|
      jb_job = JobBatch::Job.find(job.job_id)
      batch = jb_job.batch
      jb_job.destroy!

      if batch.jobs.empty?
        batch.finished!
      end
    end
  end

  protected

  def jb_job
    @_jb_job ||= JobBatch::Job.new(job_id)
  end

  def batch
    jb_job.batch
  end
end
