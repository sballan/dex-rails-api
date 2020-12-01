class AsyncRefreshScrapeBatchJob < ApplicationJob
  queue_as :refresh

  def perform(scrape_batch_id, ttl=1.minute)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find scrape_batch_id


    if scrape_batch.refresh_ready?
      scrape_batch.refresh_active!
    elsif !scrape_batch.refresh_active? && scrape_batch.scrape_pages.refresh_ready.count > 0
      scrape_batch.refresh_finished_at = nil
      scrape_batch.refresh_active!
    end

    scrape_batch.save!
    scrape_batch.reload

    if scrape_batch.refresh_active? && (Time.now.to_i < end_time)
      run_scrape_batch_command = Refresh::RefreshScrapeBatch.new(scrape_batch)
      run_scrape_batch_command.run_with_gc!
      AsyncParseScrapeBatchJob.perform_later(scrape_batch.id, end_time - Time.now.to_i)
    end
  end
end