# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  PREFIX = "Job/"

  attr_reader :batch_id

  def self.included(mod)
    mod.before_enqueue do |job|
      if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL].blank?
        raise "This should not be possible, but Thread.current has no batch_id"
      end

      batch_id = Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]

      unless JobBatch::Batch.exists?(batch_id)
        raise "This should not be possible, but somehow we opened a Batch that does not exist"
      end

      batch = JobBatch::Batch.new(batch_id)
      batch.add_job(job.job_id)
      Rails.logger.debug "Successfully added Job #{job.job_id} to Batch #{batch.id}"
    end

    mod.after_perform do |job|
      job_batch_job = JobBatch::Job.find(job.job_id)
      job_batch_job.batch.with_lock do
        job_batch_job.destroy!
      end
    end
  end

  protected

  def job_batch_job
    @_job_batch_job ||= JobBatch::Job.new(job_id)
  end

  def batch

  end

  def open_batch(&block)
    batch_id = 'find batch id'
    batch = JobBatch::Batch.new(batch_id)
    batch.open(&block)
  end
end