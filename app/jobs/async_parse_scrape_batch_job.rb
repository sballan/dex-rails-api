class AsyncParseScrapeBatchJob < ApplicationJob
  queue_as :parse

  def perform(scrape_batch_id, ttl=1.minute)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find(scrape_batch_id)

    if scrape_batch.parse_ready?
      scrape_batch.parse_active!
    elsif !scrape_batch.parse_active? && scrape_batch.scrape_pages.refresh_success.parse_ready.count > 0
      scrape_batch.parse_finished_at = nil
      scrape_batch.parse_active?
    end

    scrape_batch.save!
    scrape_batch.reload

    run_scrape_batch_command = Parse::ParseScrapeBatch.new(scrape_batch)
    run_scrape_batch_command.run_with_gc!

    AsyncRefreshScrapeBatchJob.perform_later(scrape_batch_id, end_time - Time.now.to_i)
  end
end