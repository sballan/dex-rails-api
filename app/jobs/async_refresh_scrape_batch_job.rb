class AsyncRefreshScrapeBatchJob < ApplicationJob
  queue_as :refresh

  def perform(scrape_batch_id, ttl=10.minutes)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find scrape_batch_id
    scrape_batch.refresh_active! if scrape_batch.refresh_ready?

    first_run = true

    while scrape_batch.refresh_active? && (Time.now.to_i < end_time) do
      run_scrape_batch_command = Refresh::RefreshScrapeBatch.new(scrape_batch)
      run_scrape_batch_command.run_with_gc!
      AsyncParseScrapeBatchJob.perform_later(scrape_batch.id)

      # silly hack, but let's give the parsing a chance to catch up before do these checks
      sleep 30.seconds

      scrape_batch.reload
      # Gross - but the first time this runs, there won't be any parsing happening...
      if !scrape_batch.refresh_active? && scrape_batch.scrape_pages.refresh_ready.count > 0
        scrape_batch.refresh_finished_at = nil
        scrape_batch.refresh_active!
        scrape_batch.save!
        scrape_batch.reload
      end
    end
  end
end