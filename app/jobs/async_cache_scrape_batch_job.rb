class AsyncCacheScrapeBatchJob < ApplicationJob
  queue_as :cache

  def perform(scrape_batch_id, ttl=1.minute)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find scrape_batch_id
    scrape_batch.active!

    scrape_batch.save!
    scrape_batch.reload

    if scrape_batch.scrape_pages.parse_success.any? && (Time.now.to_i < end_time)
      num_to_cache = scrape_batch.scrape_pages.parse_success.cache_ready.count

      Rails.logger.debug "[AsyncRefreshScrapeBatchJob] More pages to cache! Time left: #{end_time - Time.now.to_i}. RefreshStatus: #{scrape_batch.refresh_status}"
      Rails.logger.info "[AsyncRefreshScrapeBatchJob] Starting loop of new Command::CreatePageQueries Command"

      command = Cache::CacheScrapeBatch.new(scrape_batch)
      command.run_with_gc!

      num_left = scrape_batch.scrape_pages.parse_success.cache_ready.count
      Rails.logger.debug "[AsyncRefreshScrapeBatchJob] We went from #{num_to_cache} to #{num_left}."

    else
      Rails.logger.info "[AsyncRefreshScrapeBatchJob] No pages left to cache. Time left: #{end_time - Time.now.to_i}. RefreshStatus: #{scrape_batch.refresh_status}"
    end
  end

end