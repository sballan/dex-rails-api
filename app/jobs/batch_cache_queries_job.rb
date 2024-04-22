class BatchCacheQueriesJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :cache

  def perform(iter = 1, size = 1000)
    batch_attrs = if iter > 1
      {
        callback_klass: "BatchCacheQueriesJob",
        callback_args: [iter - 1, size]
      }
    else
      {}
    end

    query_batch = JobBatch::Batch.create(nil, batch_attrs)

    query_ids = []

    query_ids.concat(Query.never_cached.limit(size / 2).pluck(:id))
    query_ids.concat(Query.cached_before(1.week.ago).limit(size / 2).pluck(:id))

    query_batch.open do
      query_ids.each { |id| CacheQueryJob.perform_later(id) }
    end
  end
end
