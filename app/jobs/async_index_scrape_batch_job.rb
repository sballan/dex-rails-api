class AsyncIndexScrapeBatchJob < ApplicationJob
  queue_as :index

  def perform(scrape_batch_id, ttl= 1.minute)
    scrape_batch = ScrapeBatch.find scrape_batch_id
    command = Index::IndexScrapeBatch.new scrape_batch
    command.run_with_gc!

    pages_to_parse = scrape_batch.scrape_pages.refresh_success.parse_ready.any?
    pages_to_index = scrape_batch.scrape_pages.parse_success.index_ready.any?

    if pages_to_parse || pages_to_index || (scrape_page.started_at + ttl < Time.now)
      # NOTE: this is kind of a hack.  It relies on the fact that in a multithreaded system, we'll likely have started work on refreshing and parsing before this finishes.  This is bad, especially if we try scraping many batches at once.
      # Probably should pass the ttl to this method?  And cache if the ttl has passed?
      Rails.logger.info "We just indexed, but still have pages to parse or index, or ttl has not expired.   Not going to cache yet."
    else
      Rails.logger.info "We just indexed, and have nothing left to index, and ttl had expired. Let's cache."
      AsyncCacheScrapeBatchJob.perform_later(scrape_batch.id)
    end
  end

end