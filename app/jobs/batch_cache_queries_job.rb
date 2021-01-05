class BatchCacheQueriesJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :cache

  def perform(size=1000, iter=1)
    if iter > 1
      batch_attrs = {
        callback_klass: 'BatchCacheQueriesJob',
        callback_args: [size, iter - 1]
      }
    else
      batch_attrs = {}
    end

    query_batch = JobBatch::Batch.create(nil, batch_attrs)

    Query.never_cached.limit(size / 2).in_batches(of: 100) do |queries|
      query_ids = queries.pluck(:id)
      # We break this into batches of 100 so we don't lock the batch for too long at one time.
      # Maybe we don't need this, I never actually tested it.
      query_batch.open do
        query_ids.each {|id| CacheQueryJob.perform_later(id)}
      end
    end

    Query.cached_before(1.week.ago).limit(size / 2).in_batches(of: 100) do |queries|
      query_ids = queries.pluck(:id)
      # We break this into batches of 100 so we don't lock the batch for too long at one time.
      # Maybe we don't need this, I never actually tested it.
      query_batch.open do
        query_ids.each {|id| CacheQueryJob.perform_later(id)}
      end
    end
  end
end
