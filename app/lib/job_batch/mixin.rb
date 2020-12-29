# Meant to be mixed in to an instance of ActiveJob::Base
module JobBatch::Mixin
  attr_reader :batch_id

  def self.included(mod)
    mod.before_enqueue do |job|
      if Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL].present?
        batch_id = Thread.current[JobBatch::THREAD_OPEN_BATCH_SYMBOL]
        if JobBatch::Batch.exists?(batch_id)
          batch = JobBatch::Batch.new(batch_id)
          batch.add_job(job.job_id)
        else
          raise "This should not be possible, but Thread.current still has a batch id"
        end
      end
    end

    mod.after_perform do |job|

    end
  end

  protected

  def open_batch(&block)
    batch_id = 'find batch id'
    batch = JobBatch::Batch.new(batch_id)
    batch.open(&block)
  end
end