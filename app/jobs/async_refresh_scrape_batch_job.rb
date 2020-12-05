class AsyncRefreshScrapeBatchJob < ApplicationJob
  queue_as :refresh

  def perform(scrape_batch_id, ttl=1.minute)
    start_time = Time.now.to_i
    end_time = start_time + ttl.to_i

    scrape_batch = ScrapeBatch.find scrape_batch_id
    scrape_batch.active!

    scrape_batch.save!
    scrape_batch.reload

    if scrape_batch.scrape_pages.refresh_ready.any? && (Time.now.to_i < end_time)
      num_to_refresh = scrape_batch.scrape_pages.refresh_ready.count

      Rails.logger.debug "More pages to refresh! Time left: #{end_time - Time.now.to_i}. RefreshStatus: #{scrape_batch.refresh_status}"
      run_scrape_batch_command = Refresh::RefreshScrapeBatch.new(scrape_batch)
      run_scrape_batch_command.run_with_gc!

      num_left = scrape_batch.scrape_pages.refresh_ready.count

      Rails.logger.debug "We went from #{num_to_refresh} to #{num_left}.  About to hand over for parsing."

      AsyncParseScrapeBatchJob.perform_later(scrape_batch.id, end_time - Time.now.to_i)
    else
      Rails.logger.debug "No pages left to refresh. Time left: #{end_time - Time.now.to_i}. RefreshStatus: #{scrape_batch.refresh_status}"
    end
  end

end