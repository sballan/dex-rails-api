class QueueAsyncCacheScrapeBatchRangeJob < ApplicationJob
  queue_as :cache

  def perform(scrape_batch_id)
    scrape_batch = ScrapeBatch.find scrape_batch_id

    scrape_batch.queries.in_batches(of: 50) do |queries|
      start = queries.order(id: :asc).pluck(:id).first
      finish = queries.order(id: :asc).pluck(:id).last
      AsyncCacheScrapeBatchRangeJob.perform_later(scrape_batch_id, start, finish)
    end
  end
end
