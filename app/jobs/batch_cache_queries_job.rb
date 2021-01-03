class BatchCacheQueriesJob < ApplicationJob
  include JobBatch::Mixin

  queue_as :cache

  def perform(size=1000)
    Query.never_cached.limit(size).in_batches(of: 100) do |queries|
      query_ids = queries.pluck(:id)
      # We break this into batches of 100 so we don't lock the batch for too long at one time.
      # Maybe we don't need this, I never actually tested it.
      batch.open do
        query_ids.each {|id| CacheQueryJob.perform_later(id)}
      end
    end
  end
end
