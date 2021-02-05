# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  PREFIX = "Job/"

  def self.included(mod)
    # Horribly, ActiveJob will sometimes run callbacks more than once.  UGG.
    mod.before_enqueue do |job|
      Rails.logger.debug "before_enqueue callback for #{job.job_id}"

      jb_job = JobBatch::Job.find job.job_id

      # If Job is present and is in batch, just queue it up.
      if jb_job.present?
        # If Job is present and is in batch, just queue it up.
        if jb_job.batch.present?
          Rails.logger.debug "Job already exists, enqueueing existing Job #{jb_job.id}"
        else
          # if Job is present but has not batch, it's an error!
          raise "Job #{jb_job.id} already exists, but is not in Batch"
        end
      else
        Rails.logger.debug "Job does not exist, creating it now"

        if JobBatch::Batch.opened_batch.present?
          Rails.logger.debug "There is an open batch, so let's use it"
          batch = JobBatch::Batch.opened_batch
        else
          Rails.logger.debug "There is no currently open batch, so let's create one"
          batch = JobBatch::Batch.create
        end

        jb_job = JobBatch::Job.create(job.job_id, batch_id: batch.id)
        Rails.logger.debug "Successfully added Job #{jb_job.id} to Batch #{jb_job.batch.id}"
      end
    end

    mod.after_perform do |job|
      Rails.logger.debug "after_perform callback for #{job.job_id}"

      jb_job = JobBatch::Job.find(job.job_id)

      if jb_job.blank?
        raise "Job performed, but JobBatch::Job #{job.job_id} could not be found in Redis"
      end

      batch = jb_job.batch
      jb_job.destroy!

      begin
        batch.with_lock(nil, retry_time: 0.seconds) do |lock_key|
          if batch.jobs.empty? && batch.children.empty?
            batch.finished!(lock_key)
          end
        end
      rescue => e
        # TODO: don't just rescue any error, if we can't get the lock that's ok
        Rails.logger.error e
      end
    end
  end

  protected

  def jb_job
    @_jb_job ||= JobBatch::Job.find(job_id)
  end

  def batch
    jb_job && jb_job.batch
  end
end
