class AsyncCacheScrapeBatchJob < ApplicationJob
  queue_as :cache

  def perform(scrape_batch_id)
    scrape_batch = ScrapeBatch.find scrape_batch_id
    scrape_batch.active!

    command = Cache::CacheScrapeBatch.new(scrape_batch)
    command.run_with_gc!

    if command.success?
      scrape_batch.cache_status = :success
      scrape_batch.status = :success
    else
      scrape_batch.cache_status = :failure
      scrape_batch.status = :failure
    end
    scrape_batch.cache_finished_at = DateTime.now.utc

    scrape_batch.save!
  end
end
