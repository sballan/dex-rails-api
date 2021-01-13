# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  PREFIX = "Job/"

  attr_reader :batch_id

  def self.included(mod)
    mod.before_enqueue do |job|
      jb_job = JobBatch::Job.find job.job_id

      # If Job is present and is in batch, just queue it up.
      if jb_job.present?
        # If Job is present and is in batch, just queue it up.
        if jb_job.batch.present?
          Rails.logger.debug "Job already exists, enqueueing existing Job #{jb_job.id}"
          return
        else
          # if Job is present but has not batch, it's an error!
          raise "Job #{jb_job.id} already exists, but is not in Batch"
        end
      else
        Rails.logger.info "Job does not exist, creating it now"

        if JobBatch::Batch.opened_batch.present?
          Rails.logger.debug "There is an open batch, so let's use it"
          batch = JobBatch::Batch.opened_batch
        else
          Rails.logger.debug "There is no currently open batch, so let's create one"
          batch = JobBatch::Batch.create
        end

        jb_job = JobBatch::Job.create(job.job_id, batch_id: batch.id)
        Rails.logger.debug "Successfully added Job #{jb_job.id} to Batch #{batch.id}"
      end
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
