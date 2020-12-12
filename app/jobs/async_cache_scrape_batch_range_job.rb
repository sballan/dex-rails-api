class AsyncCacheScrapeBatchRangeJob < ApplicationJob
  queue_as :cache

  def perform(scrape_batch_id, start, finish, of=25)
    scrape_batch = ScrapeBatch.find scrape_batch_id
    command = Cache::CacheScrapeBatchRange.new(scrape_batch, start, finish)
    command.run_with_gc!
  end
end
