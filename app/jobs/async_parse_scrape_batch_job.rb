class AsyncParseScrapeBatchJob < ApplicationJob
  queue_as :parse

  def perform(scrape_batch_id, ttl=1.minute)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find(scrape_batch_id)

    if scrape_batch.scrape_pages.refresh_success.parse_ready.count > 0
      Rails.logger.debug "[AsyncParseScrapeBatchJob] ScrapeBatch (#{scrape_batch.id}) has pages to parse"
      scrape_batch.parse_active!
      scrape_batch.parse_finished_at = nil
      scrape_batch.parse_active!
    else
      Rails.logger.info "[AsyncParseScrapeBatchJob] Nothing to parse!"
    end

    scrape_batch.save!
    scrape_batch.reload

    run_scrape_batch_command = Parse::ParseScrapeBatch.new(scrape_batch)
    run_scrape_batch_command.run_with_gc!

    scrape_batch.reload
    if scrape_batch.scrape_pages.refresh_ready.any?
      Rails.logger.debug "We just parsed, and have #{scrape_batch.scrape_pages.refresh_ready.count} to refresh"
      scrape_batch.refresh_active!
      scrape_batch.save!
      AsyncRefreshScrapeBatchJob.perform_later(scrape_batch_id, end_time - Time.now.to_i)
    elsif scrape_batch.scrape_pages.refresh_success.parse_ready?
      Rails.logger.debug "We just parsed, but have more work to do! IMPLEMENT THIS"
    end

    scrape_batch.scrape_pages.parse_success.cache_ready.in_batches.each_record do |scrape_page|
      Rails.logger.debug "We just parsed, and have #{scrape_batch.scrape_pages.parse_success.cache_ready.count} to cache"
      scrape_page.cache_active!
      AsyncCacheScrapePageJob.perform_later(scrape_page.id)
    end
  end
end