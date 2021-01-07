# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  PREFIX = "Job/"

  attr_reader :batch_id

  def self.included(mod)
    mod.before_enqueue do |job|
      batch = JobBatch::Batch.opened_batch

      if JobBatch::Batch.opened_batch.blank?
        Rails.logger.debug "There is no currently open batch, so let's create one"
        batch = JobBatch::Batch.create
      end

      jb_job = JobBatch::Job.find_or_create(job.job_id, batch_id: batch.id)
      Rails.logger.debug "Successfully added Job #{jb_job.id} to Batch #{batch.id}"
    end

    mod.after_perform do |job|
      jb_job = JobBatch::Job.find(job.job_id)

      if jb_job.blank?
        raise "Job performed, but JobBatch::Job #{job.job_id} could not be found in Redis"
      end

      batch = jb_job.batch
      jb_job.destroy!

      if batch.jobs.empty? && batch.children.empty?
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
