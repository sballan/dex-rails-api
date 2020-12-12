class AsyncRefreshScrapeBatchJob < ApplicationJob
  queue_as :refresh

  def perform(scrape_batch_id, ttl=1.minute)
    scrape_batch = ScrapeBatch.find scrape_batch_id
    scrape_batch.active!

    if scrape_batch.scrape_pages.refresh_ready.any? && (scrape_batch.started_at + ttl > Time.now)
      num_to_refresh = scrape_batch.scrape_pages.refresh_ready.count

      Rails.logger.debug "More pages to refresh! Time left: #{scrape_batch.started_at + ttl - Time.now}"
      Rails.logger.info "[AsyncRefreshScrapeBatchJob] Starting new Refresh::RefreshScrapeBatch Command"
      run_scrape_batch_command = Refresh::RefreshScrapeBatch.new(scrape_batch)
      run_scrape_batch_command.run_with_gc!

      num_left = scrape_batch.scrape_pages.refresh_ready.count

      Rails.logger.debug "We went from #{num_to_refresh} to #{num_left}.  About to hand over for parsing."

      AsyncParseScrapeBatchJob.perform_later(scrape_batch.id, ttl)
    elsif scrape_batch.started_at + ttl > Time.now
      Rails.logger.info "Nothing left to refresh or parse, time still left on the clock."
    else
      Rails.logger.info "Time has expired"
    end
  end

end